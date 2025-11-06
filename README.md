# GitLab Code Review

A Rails application for exporting, tracking, and managing GitLab merge request feedback. This tool helps teams review and track code review comments across GitLab merge requests.

## Features

- **Export MR Feedback**: Extract all comments and discussions from a GitLab merge request
- **Track Review Status**: Mark individual feedback items as reviewed with visual indicators
- **Automatic Detection**: Automatically identifies feedback already marked with ✅ emoji in GitLab
- **Sync to GitLab**: Add check mark reactions back to GitLab when marking items as reviewed
- **Review History**: View all exported merge requests and their review status
- **Web Interface**: Simple, intuitive web UI for managing reviews

## Prerequisites

- Docker and Docker Compose (for local development)
- GitLab account with API access
- GitLab Personal Access Token with `api` scope

## Local Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd gitlab-code-review
```

### 2. Configure Environment

Create a `.gitlab.pwd` file in the root directory with your GitLab personal access token:

```bash
echo "your-gitlab-token-here" > .gitlab.pwd
```

The `.env` file is already configured to read from this file:

```bash
GITLAB_TOKEN=$(cat .gitlab.pwd)
GITLAB_ENDPOINT=https://gitlab.com/api/v4
```

**Note**: Update `GITLAB_ENDPOINT` if you're using a different GitLab instance.

### 3. Start the Development Environment

This project uses Docker containers for development. Open the project in a devcontainer-compatible editor (VS Code with Dev Containers extension recommended), or manually start the containers:

```bash
docker-compose -f .devcontainer/docker-compose.yml up -d
docker-compose -f .devcontainer/docker-compose.yml exec app bash
```

### 4. Setup the Database

Inside the container:

```bash
bundle install
rails db:create
rails db:migrate
```

### 5. Start the Rails Server

```bash
rails server -b 0.0.0.0
```

The application will be available at `http://localhost:3000`

## Configuration

### GitLab Token

To create a GitLab Personal Access Token:

1. Go to GitLab → User Settings → Access Tokens
2. Create a new token with `api` scope
3. Copy the token and save it to `.gitlab.pwd`

### Database

The application uses PostgreSQL. The development environment is configured with:
- **Host**: db (Docker service)
- **User**: postgres
- **Password**: postgres
- **Database**: gitlab_code_review_development

## Technology Stack

- **Ruby**: 3.3.10
- **Rails**: 7.1.6
- **Database**: PostgreSQL
- **API Client**: gitlab gem (Ruby GitLab API client)
- **Web Server**: Puma
- **Container**: Docker with devcontainer support

## Project Structure

```
gitlab-code-review/
├── app/
│   ├── controllers/     # Web and API controllers
│   ├── models/          # Export and Feedback models
│   ├── services/        # GitLab API service
│   └── views/           # HTML templates
├── config/              # Rails configuration
├── db/                  # Database migrations and schema
├── .devcontainer/       # Docker development environment
├── Gemfile              # Ruby dependencies
└── .env                 # Environment variables
```

## Development

### Running Tests

```bash
rails test
```

### Rails Console

```bash
rails console
```

### Database Operations

```bash
# Reset database
rails db:reset

# View schema
rails db:schema:dump
```

## Troubleshooting

### Container Not Starting

Ensure Docker is running and ports 3000 (app) and 5432 (postgres) are not in use.

### GitLab API Errors

- Verify your token has `api` scope
- Check that `GITLAB_ENDPOINT` matches your GitLab instance
- Ensure the token hasn't expired

### Database Connection Issues

If you can't connect to the database, restart the containers:

```bash
docker-compose -f .devcontainer/docker-compose.yml restart
```

## Usage

See [USAGE.md](USAGE.md) for detailed usage instructions.

## License

See LICENSE file for details.
