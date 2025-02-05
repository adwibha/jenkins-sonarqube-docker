from flask import Flask, render_template
import speedtest

app = Flask(__name__)

@app.route('/')
def home():
    st = speedtest.Speedtest()

    # Get the best server
    st.get_best_server()

    # Perform download, upload, and ping tests
    download_speed = st.download() / 1_000_000  # Convert to Mbps
    upload_speed = st.upload() / 1_000_000      # Convert to Mbps
    ping = st.results.ping

    # Render the results in HTML
    return render_template('index.html', download_speed=download_speed, upload_speed=upload_speed, ping=ping)

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=80)
