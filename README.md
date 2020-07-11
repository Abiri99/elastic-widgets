
# Elastic Widgets  
  
Set of Flutter widgets built using physics based animations.  
  
  
# Widgets  
  
| Slider ![seekbar gif](https://github.com/Abiri99/elastic-widgets/blob/master/repo_files/gif/seekbar.gif?raw=true) | Range Picker ![enter image description here](https://github.com/Abiri99/elastic-widgets/blob/master/repo_files/gif/range-picker.gif?raw=true) |  
|--|--|  
|  |  |  
  
  
## Installation  
##### Add this to your package's pubspec.yaml file  
  
```yml  
dependencies:  
 elastic_widgets: 0.0.1
 ```  
  
## Usage  
  
 ### Seek bar: 
 ``` dart
 ElasticSeekBar(
	 valueListener: (value) {    
	   print("slider value: $value");    
	 },    
	 size: Size(300, 100),    
	 stretchRange: 50.0,    
	 minValue: 0,    
	 maxValue: 100,    
	 circleRadius: 12,    
	 thinLineStrokeWidth: 3,    
	 thickLineStrokeWidth: 4,    
	 thickLineColor: Colors.blue,    
	 thinLineColor: Colors.blueGrey,    
	 bounceDuration: Duration(seconds: 1),    
	 stiffness: 300,    
	 dampingRatio: 5,
),  
 ``` 
 ### Range picker:  
 ``` dart
 ElasticRangePicker(    
	 valueListener: (firstValue, secondValue) {    
	   print("range picker first value: $firstValue");    
	   print("range picker second value: $secondValue");    
	 },    
	 size: Size(300, 100),    
	 stretchRange: 50.0,    
	 minValue: 0,    
	 maxValue: 100,    
	 circleRadius: 12,    
	 thinLineStrokeWidth: 3,    
	 thickLineStrokeWidth: 4,    
	 thickLineColor: Colors.orange,    
	 thinLineColor: Colors.blueGrey,    
	 bounceDuration: Duration(seconds: 1),    
	 stiffness: 300,    
	 dampingRatio: 5, 
),  
 ```  
  
## Planned widgets  
  
 - [ ] Radio button  
 - [ ] Checkbox  
 - [ ] Dialog  
 - [ ] Button  
##
**Made with :heart: for Flutter community** -   **Pull requests are welcome** :sparkles:

keywords: widget, elastic, slider, seekbar, seek bar, range picker, rangepicker