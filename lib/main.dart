import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

part 'main.g.dart';

final selectedCityProvider = StateProvider<String>((_) => 'here');

@riverpod
Dio appDio(AppDioRef ref) {
  final token = dotenv.env['WAQI_API_KEY']?.trim() ?? '';
  if (token.isEmpty) throw StateError('Missing WAQI_API_KEY in .env');

  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.waqi.info',
    queryParameters: {'token': token},
  ));

  if (kDebugMode) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) {
        print('🌐 Request → ${opts.uri}');
        handler.next(opts);
      },
      onResponse: (resp, handler) {
        print('🌐 Response → ${resp.data}');
        handler.next(resp);
      },
      onError: (e, handler) {
        print('❌ Dio error → ${e.message}');
        handler.next(e);
      },
    ));
  }

  return dio;
}

class AqiInfo {
  final int aqi;
  final String cityName;
  AqiInfo(this.aqi, this.cityName);

  factory AqiInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final city = data['city'] as Map<String, dynamic>;
    return AqiInfo(
      data['aqi'] as int,
      city['name'] as String,
    );
  }
}

final aqiProvider = FutureProvider<AqiInfo>((ref) async {
  final city = ref.watch(selectedCityProvider);
  final dio = ref.watch(appDioProvider);
  final resp = await dio.get('/feed/$city/');
  final json = resp.data as Map<String, dynamic>;
  if (json['status'] != 'ok') {
    throw Exception('Unknown station');
  }
  return AqiInfo.fromJson(json);
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: AqiApp()));
}

class AqiApp extends StatelessWidget {
  const AqiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirChecker',
      theme: ThemeData.dark(useMaterial3: true),
      home: const AqiHome(),
    );
  }
}

class AqiHome extends ConsumerWidget {
  const AqiHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(selectedCityProvider);
    final state = ref.watch(aqiProvider);
    final controller = TextEditingController(text: city);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              hintText: 'Search city…',
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.grey.shade900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              final slug = value.trim();
              if (slug.isNotEmpty) {
                ref.read(selectedCityProvider.notifier).state = slug;
              }
            },
          ),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
        error: (err, _) {
          final msg = err.toString().contains('Unknown station')
              ? "Sorry, we couldn't find your city at the moment.\nPlease try again."
              : err.toString();
          return Center(
            child: Text(
              msg,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          );
        },
        data: (info) => _buildContent(info),
      ),
    );
  }

  Widget _buildContent(AqiInfo info) {
    final color = _getStatusColor(info.aqi);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hi Arthur, 😊',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 55,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'How is the air today?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: const Color(0xFF1E1E1E),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        info.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 160,
                        child: SfRadialGauge(
                          axes: <RadialAxis>[
                            RadialAxis(
                              showTicks: false,
                              showLabels: false,
                              startAngle: 180,
                              endAngle: 0,
                              minimum: 0,
                              maximum: 300,
                              axisLineStyle: AxisLineStyle(
                                thickness: 16,
                                cornerStyle: CornerStyle.bothCurve,
                                color: Colors.grey.shade800,
                              ),
                              pointers: <GaugePointer>[
                                RangePointer(
                                  value: info.aqi.toDouble(),
                                  cornerStyle: CornerStyle.bothCurve,
                                  width: 16,
                                  sizeUnit: GaugeSizeUnit.logicalPixel,
                                  gradient: const SweepGradient(
                                    colors: [
                                      Colors.greenAccent,
                                      Colors.yellowAccent,
                                      Colors.orangeAccent,
                                      Colors.redAccent,
                                      Colors.purpleAccent
                                    ],
                                    stops: [0, .2, .4, .6, .8],
                                  ),
                                )
                              ],
                              annotations: <GaugeAnnotation>[
                                GaugeAnnotation(
                                  positionFactor: 0.6,
                                  angle: 90,
                                  widget: Column(
                                    children: [
                                      Text(
                                        '${info.aqi}',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getStatusLabel(info.aqi),
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getEmoji(info.aqi),
                        style: const TextStyle(fontSize: 32),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(int aqi) {
    if (aqi <= 50) return Colors.greenAccent;
    if (aqi <= 100) return Colors.yellowAccent;
    if (aqi <= 150) return Colors.orangeAccent;
    if (aqi <= 200) return Colors.redAccent;
    if (aqi <= 300) return Colors.purpleAccent;
    return Colors.deepPurpleAccent;
  }

  String _getStatusLabel(int aqi) {
    if (aqi <= 50) return 'GOOD';
    if (aqi <= 100) return 'MODERATE';
    if (aqi <= 150) return 'HAZARDOUS';
    if (aqi <= 200) return 'UNHEALTHY';
    if (aqi <= 300) return 'VERY UNHEALTHY';
    return 'SEVERE';
  }

  String _getEmoji(int aqi) {
    if (aqi <= 50) return '😊';
    if (aqi <= 100) return '😐';
    if (aqi <= 150) return '😷';
    if (aqi <= 200) return '🤢';
    return '☠️';
  }
}
