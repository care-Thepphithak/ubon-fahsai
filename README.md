# 🔥 Ubon Fahsai - Fire Event Reporting PWA

Ubon Fahsai is a Progressive Web Application built with Ruby on Rails that enables citizens to report fire events in their city. The application leverages location tracking, photo uploads, and interactive maps to provide timely information about fire incidents to authorities.

## ✨ Features

- **Location-Based Reporting**: Automatically tracks user location for accurate incident reporting
- **Photo Evidence**: Users can take photos of fire incidents directly through the app
- **Interactive Map**: Repositionable pin for precise location reporting
- **Detailed Descriptions**: Users can provide additional context about the fire event
- **Admin Dashboard**: Authorities can monitor and manage reported fire incidents
- **Progressive Web App**: Works on multiple devices with offline capabilities

## 🛠️ Technical Stack

* **Ruby**: 3.3.2
* **Rails**: 8.0.1
* **Database**: PostgreSQL
* **Frontend**: HTML, CSS, JavaScript
* **Maps**: Leaflet
* **Image Storage**: Active Storage with MinIO
* **Containerization**: Docker
* **CI/CD**: GitLab CI

## 🚀 Setup and Installation

### Prerequisites
- Ruby 3.3.2
- Rails 8.0.1
- PostgreSQL
- Docker and Docker Compose

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://gitlab.odds.team/KhonKaen/Ubon-Fahsai/ubon-fahsai.git
   cd ubon-fahsai
   ```
   or using SSH
   ```bash
   git clone git@gitlab.odds.team:KhonKaen/Ubon-Fahsai/ubon-fahsai.git
   cd ubon-fahsai
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Database setup**

    **For Development**: Use our complete Docker Compose setup
    ```bash
    docker-compose -f docker-compose.local.yml up -d
    ```
    
    **For Production**: Create `.env` file with the following variables:
    ```
    MINIO_ROOT_USER="Your MinIO username"
    MINIO_ROOT_PASSWORD="Your MinIO password"
    MINIO_ACCESS_KEY="Your MinIO access key"
    MINIO_KEY_ID="Your MinIO secret key id"
    MINIO_BUCKET="Your MinIO bucket"
    POSTGRES_HOST="Your PostgreSQL host"
    POSTGRES_USER="Your PostgreSQL user"
    POSTGRES_PASSWORD="Your PostgreSQL password"
    POSTGRES_DB="Your PostgreSQL db"
    MINIO_ENDPOINT="Your MinIO endpoint" # Ex. http://localhost:9000
    ```

4. **Start the server**
   ```bash
   rails server
   ```

## 💻 Development

### Running Tests
```bash
rails db:prepare
rails db:migrate
rails test
```
Make sure that you already create database or prepare database

### Development Workflow
Before running development scripts, please complete the database setup step first.

1. Start Docker Compose database
```bash
docker-compose -f docker-compose.local.yml up -d
```

2. Start Rails server
```bash
rails server
```

### Production Deployment
Before running production scripts, please complete the production database setup step first.

1. Start Docker Compose for production mode
```bash
docker-compose up -d
```

## 📱 Usage

### User Flow
1. Navigate to the application
2. Allow location access when prompted
3. Click on "Report Fire"
4. Take a photo or upload one from your device
5. Add details about the incident
6. Adjust the pin to the exact fire location if needed
7. Submit the report

### Admin Dashboard
Access the admin dashboard at `/admin/dashboard` with appropriate credentials to:
- View all reported incidents
- Filter reports by date, location, or status
- Manage incident response
- Export data for reporting

## 🌐 Deployment Options

The application is designed to be deployed on:
- AWS
- Azure

Deployment instructions: <br>
**🚧 Coming Soon..**

## 👥 Contributing

1. Fork the repository
2. Create a feature branch (`git switch feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🔗 Links

- [Project Repository](https://gitlab.odds.team/KhonKaen/Ubon-Fahsai/ubon-fahsai)
- [Issue Tracker](https://gitlab.odds.team/KhonKaen/Ubon-Fahsai/ubon-fahsai/issues)