import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class YandexWeatherWidget extends StatefulWidget {
  const YandexWeatherWidget({super.key});

  @override
  State<YandexWeatherWidget> createState() => _YandexWeatherWidgetState();
}

class _YandexWeatherWidgetState extends State<YandexWeatherWidget> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _errorMessage = '';
  final String _apiKey =
      'efbe943f-23bc-41b5-8580-ac878f1cbc09'; // Замените на ваш ключ
  final double _latitude = 56.141253; // Широта (Москва)
  final double _longitude = 47.230003; // Долгота (Москва)

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.weather.yandex.ru/v2/forecast?lat=$_latitude&lon=$_longitude&lang=ru_RU',
        ),
        headers: {'X-Yandex-API-Key': _apiKey},
      );

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
        });
      } else {
        setState(() {
          _errorMessage = 'Ошибка загрузки данных: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(_weatherData);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Погода ${''}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _fetchWeatherData,
                  tooltip: 'Обновить',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else if (_weatherData != null)
              _buildWeatherContent()
            else
              const Text('Данные о погоде недоступны'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent() {
    final fact = _weatherData!['fact'];
    final String iconUrl =
        'https://yastatic.net/weather/i/icons/blueye/color/svg/${fact['icon']}.svg';
    final date = DateTime.parse(_weatherData!['now_dt']);

    return Column(
      children: [
        Row(
          children: [
            SvgPicture.network(
              iconUrl,
              width: 64,
              height: 64,
              placeholderBuilder: (context) =>
                  const CircularProgressIndicator(),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fact['temp']}°C',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ощущается как ${fact['feels_like']}°C',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildWeatherDetail(
              'Влажность',
              '${fact['humidity']}%',
              Icons.water_drop,
            ),
            _buildWeatherDetail(
              'Ветер',
              '${fact['wind_speed']} м/с',
              Icons.air,
            ),
            _buildWeatherDetail(
              'Давление',
              '${fact['pressure_mm']} мм рт. ст.',
              Icons.speed,
            ),
            _buildWeatherDetail(
              'Облачность',
              '${fact['cloudness']}%',
              Icons.cloud,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Обновлено: ${DateFormat.Hm().format(date)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
