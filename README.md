# Stacked News Viewer App

A simple Flutter application that fetches and displays the latest news articles using the [NewsAPI](https://newsapi.org/). It allows users to swipe through news cards and view details about each article such as title, description, image, and source.

## Features

- Fetches top headlines from various countries.
- Displays news articles with title, description, and source.
- Swipe up or down to navigate between articles.
- Displays a progress indicator while loading news.
- Retry mechanism if there is an error fetching the news.
- Supports dark mode.

## API key
- const apiKey = 'YOUR_NEWSAPI_KEY'.

## Screenshots

![App Screenshot 1](screenshots/screenshot1.png)
![App Screenshot 2](screenshots/screenshot2.png)

## Getting Started

To run this project on your local machine, follow these steps:

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- A valid [NewsAPI key](https://newsapi.org/) for fetching news articles.

### Clone the Repository

```bash
git clone https://github.com/yourusername/newsapp.git
cd newsapp
