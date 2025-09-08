# openSIS (student)

This is a PHP openSIS instance prepared for deployment.

What I changed to make this repo deployable:
- Added `Data.php` to read DB and app settings from environment variables.
- Added `.gitignore` and `.env.example` to avoid committing secrets.
- Added a simple `Dockerfile` to run on Render or locally.

Local development
1. Copy `.env.example` to `.env` and set credentials.
2. Serve with PHP built-in server for quick tests:

   php -S 0.0.0.0:8080 -t .

Deploying to Render
1. Create a new Web Service on Render.
2. Connect your GitHub repository.
3. Set environment variables (DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS) in the Render dashboard. Use a managed database or external provider.
4. Use the provided `Dockerfile` or set the build and start commands to use PHP.

Notes
- Database credentials must be provided by the platform; the app will read them from environment variables.
- I avoided changing application code paths; most DB calls use the global variables defined in `Data.php`.

Next steps I can take for you
- Replace any remaining hard-coded DB connection attempts in files that bypass `DatabaseInc.php` to use the globals (I can scan and fix).
- Add a small health-check endpoint and a `render.yaml` config if you want to use Render's native settings.
