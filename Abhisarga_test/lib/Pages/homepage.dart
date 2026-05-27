import 'package:abhisarga_test/Pages/mlpredictorpage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../Models/weatherApiService.dart';
import '../Resources/appLocalizations.dart';
import '../Resources/defaultTheme.dart';
import '../Resources/languageChanger.dart';
import 'recommendationpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DefaultTheme defaultTheme = DefaultTheme();
  Map<String, dynamic> todayWeather = {};
  List<Map<String, dynamic>> forecastWeather = [];

  @override
  void initState() {
    super.initState();
    _getWeatherForecast();
  }

  Future<void> _getWeatherForecast() async {
    try {
      Position position = await getUserLocation();
      Map<String, dynamic> todayForecastData =
          await predictTodayForecast(position);
      Map<String, dynamic> forecastData = await predictForecast(position);

      if (todayForecastData.containsKey('today')) {
        setState(() {
          todayWeather = todayForecastData['today'];
        });
      }

      if (forecastData.containsKey('forecast')) {
        setState(() {
          forecastWeather =
              List<Map<String, dynamic>>.from(forecastData['forecast']);
        });
      }
    } catch (e) {
      setState(() {
        print("Error: $e");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(136, 179, 247, 1),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage(
                'assets/images/logo.jpg'), // Replace with your logo path
            radius: 20, // Adjust the size as needed
            backgroundColor: Colors.transparent, // Removes background if needed
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate("Home Page"),
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true, // Ensures the title is centered
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                todayWeather.isNotEmpty
                    ? _weatherCard()
                    : _loadingWeatherCard(),
                const SizedBox(height: 35),
                forecastWeather.isNotEmpty
                    ? _forecastList()
                    : _loadingForecastList(),
                const SizedBox(height: 30),
                _simpleButton(
                    AppLocalizations.of(context)!
                        .translate("Go to Recommendation"), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecommendationPage()),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30), // 80% curve
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PredictorPage()),
            );
          },
          backgroundColor: Color.fromRGBO(136, 179, 247, 1),
          child: const Icon(Icons.camera_alt_outlined, size: 35),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Moves up
    );
  }

  Widget _weatherCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Color.fromRGBO(100, 181, 5, 1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Weather - ${todayWeather['Date']}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            _weatherRow("🌡 Temp:",
                "${_formatValue(todayWeather['Temperature (°C)'])}°C"),
            _weatherRow("💧 Humidity:",
                "${_formatValue(todayWeather['Humidity (%)'])}%"),
            _weatherRow("🌬 Wind:",
                "${_formatValue(todayWeather['Wind Speed (m/s)'])} m/s"),
            _weatherRow("🌧 Rainfall:",
                "${_formatValue(todayWeather['Rainfall (mm)'])} mm"),
          ],
        ),
      ),
    );
  }

  Widget _loadingWeatherCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(4, (index) => _loadingBox()),
        ),
      ),
    );
  }

  Widget _forecastList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastWeather.length,
        itemBuilder: (context, index) {
          return _forecastCard(forecastWeather[index]);
        },
      ),
    );
  }

  Widget _forecastCard(Map<String, dynamic> forecast) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color.fromRGBO(100, 181, 5, 0.3),
      margin: const EdgeInsets.only(right: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(forecast['Date'] ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _forecastRow(
                "🌡", "${_formatValue(forecast['Avg Temperature (°C)'])}°C"),
            _forecastRow(
                "💧", "${_formatValue(forecast['Avg Humidity (%)'])}%"),
            _forecastRow(
                "🌬", "${_formatValue(forecast['Avg Wind Speed (m/s)'])} m/s"),
            _forecastRow(
                "🌧", "${_formatValue(forecast['Total Rainfall (mm)'])} mm"),
          ],
        ),
      ),
    );
  }

  Widget _loadingForecastList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  Widget _simpleButton(String text, VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Color.fromRGBO(136, 179, 247, 1),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _weatherRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text("$label $value",
          style: const TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _forecastRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Text("$emoji $text", style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _loadingBox() {
    return Container(
      height: 15,
      width: 120,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: Colors.grey.shade400, borderRadius: BorderRadius.circular(5)),
    );
  }

  String _formatValue(dynamic value) {
    return value == null
        ? "0.00"
        : (value is num ? value.toStringAsFixed(2) : "0.00");
  }
}
