# AgriVision

AgriVision is an advanced AI-powered mobile application designed to assist farmers with weather forecasting, crop and fertilizer recommendations, and plant disease & pest classification. The app provides a user-friendly interface with local language support, ensuring accessibility even in rural areas.

## Features

### 🌦 Weather Forecasting
- Provides daily and 6-day weather forecasts.
- Helps farmers plan agricultural activities based on weather conditions.

### 🌱 Crop and Fertilizer Recommendation
- Uses soil data such as:
  - **NPK Levels** (Nitrogen, Phosphorus, Potassium)
  - **pH Levels**
  - **Rainfall**
  - **Soil Moisture**
- Suggests optimal crops and fertilizers to enhance productivity.

### 🦠 Plant Disease & Pest Classification
- **Online Mode:** Uses real-time data from the latest AI models.
- **Offline Mode:** Utilizes a locally stored model to classify diseases even in areas with low internet connectivity.
- Trained on a **vast dataset with 55 plant disease and pest classes**.

### 🌍 Local Language Support
- Ensures ease of use for farmers in rural areas by integrating multiple language options.

## Technologies Used
- **Machine Learning**: CNN-based plant disease and pest classification.
- **Deep Learning**: LLM APIs for enhanced recommendations.
- **API Integration**: Real-time weather and soil analysis.
- **Mobile App Development**: User-friendly UI with multilingual support.

## Installation & Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/sujithvaishnav/AgriVision.git
   ```
2. Navigate to the project folder:
   ```bash
   cd AgriVision
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the application:
   ```bash
   python app.py
   ```

## Screenshots

### 📌 Home Page
![Home Page](screenshots/home.jpg)

### 🌱 Crop Recommendation and Fertilizer Recommendation
![Crop Recommendation](screenshots/crop_recommendation.jpg)
![Fertilizer Recommendation](screenshots/fertilizer_recommendation.jpg)

### 🦠 Disease & Pest Classification
![Disease & Pest Classification](screenshots/disease_classification.jpg)

### 🛠 Local Language Support
![Settings](screenshots/Language.jpg)


## Contributing
We welcome contributions! Feel free to fork the repository and submit pull requests.

## License
This project is licensed under the MIT License.

## Contact
For any inquiries or support, reach out via [GitHub Issues](https://github.com/sujithvaishnav/AgriVision/issues).
