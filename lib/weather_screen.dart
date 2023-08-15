import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secret_key.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});
  
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  Future<Map<String,dynamic>> getCurrentWeather() async {
    String cityName = 'London';
    print('future fn');
     
    try{
      final res = await http.get(
      (Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'))
      );
      print('api ended');
      final data = jsonDecode(res.body);
      // if (data['cod'] != '200'){
      //   throw ('An unexpected error occurred ! ');
      // }
      print(data['list'][0]['main']['temp']);
  
      return data;
      // setState(() {
      //   currentTemp = data['list'][0]['main']['temp'];
      // }); 
      } catch(e) {
        throw e.toString();
    }
 
  }

  @override
  void initState() {
    super.initState();
    print('initState');
    getCurrentWeather();

  }

  @override
  Widget build(BuildContext context) {
    print('build fn');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){ 
              setState(() {
              });  
            }, 
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          // print(snapshot);
          // print(snapshot.runtimeType);
          if ( snapshot.connectionState == ConnectionState.waiting ) {  return const Center( child: CircularProgressIndicator()); }
          else if ( snapshot.hasError ) { return Text (' ${snapshot.error.toString()}'); }

          // if ( snapshot.hasData ) {print (snapshot.data.toString());}

          final data = snapshot.data!; // data! = no null
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentHumidity = data['list'][0]['main']['humidity'];
          final currentWindspeed = data['list'][0]['wind']['speed'];
          final currentPressure = data['list'][0]['main']['pressure'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child :
                    Card(
                      elevation: 10,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$currentTemp K',
                              style: const TextStyle(
                              fontSize: 30
                              ),
                            ),
                            const SizedBox(height: 10),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain' ?
                              Icons.cloud : 
                              Icons.sunny,
                              size: 40),
                            const SizedBox(height: 10),
                             Text(
                              '$currentSky',
                              style: const TextStyle(
                                fontSize: 25
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ),
                const SizedBox(height: 10),           
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //         HourlyForecastItem(time:'09:00',icon: Icons.cloud,temperature:'90'),
                //         HourlyForecastItem(time:'09:00',icon: Icons.cloud,temperature:'90'),
                //         HourlyForecastItem(time:'09:00',icon: Icons.cloud,temperature:'90'),
                //         HourlyForecastItem(time:'09:00',icon: Icons.cloud,temperature:'90'),
                //         HourlyForecastItem(time:'09:00',icon: Icons.cloud,temperature:'90'),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 125,
                  child: ListView.builder(
                    
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index){
                
                      // final hourlyWeatherTime = data['list'][index+1]['dt'].toString();
                      final hourlyWeatherMain = data['list'][index+1]['weather'][0]['main'];
                      final hourlyWeatherTemp = data['list'][index+1]['main']['temp'].toString();
                      final time = DateTime.parse(data['list'][index+1]['dt_txt']);
               
                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icon : hourlyWeatherMain == 'Rain'|| hourlyWeatherMain == 'Clouds' ? Icons.cloud : Icons.sunny, 
                        temperature: hourlyWeatherTemp
                      );
                
                    }),
                ),

                const SizedBox(height: 10),  
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem( icon: Icons.water_drop, label: 'Humidity', value: currentHumidity.toString()),
                    AdditionalInfoItem( icon: Icons.air, label: 'Wind Speed', value: currentWindspeed.toString()),
                    AdditionalInfoItem( icon: Icons.beach_access, label: 'Pressure', value: currentPressure.toString()),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}



