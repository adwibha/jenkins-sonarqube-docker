# **🚀 CI/CD Pipeline with Jenkins, GitHub, SonarQube, and Docker on AWS EC2**

## **📌 Introduction**  
A step-by-step approach to setting up a **Jenkins CI/CD pipeline** integrated with **GitHub, SonarQube, and Docker** on an **AWS EC2 instance**.

### **🔹 Pipeline Workflow**
1. **Code Push**: Developer pushes code to GitHub.
2. **Build & Test**: Jenkins pulls the latest code and builds the project.
3. **Static Code Analysis**: SonarQube analyzes the code for quality and security issues.
4. **Deployment**: If tests and code quality checks pass, the application is deployed using Docker.

## **📌 Prerequisites**
- **AWS EC2 Instances**  
  - `Jenkins Server`
  - `SonarQube Server`
  - `Docker Server`
- **GitHub Repository** (with application code)
- **Basic Knowledge** of Jenkins, SonarQube, and Docker



# **🚀 Step 1: Setting Up AWS EC2 Instances**
For best performance and security, use **three separate** EC2 instances:
1. **Jenkins Server**
2. **SonarQube Server**
3. **Docker Server**

Make sure **security groups** allow required ports:
- **Jenkins:** `8080`
- **SonarQube:** `9000`
- **Docker:** `2376` (if remotely managing)

# **⚙️ Step 2: Installing and Configuring Jenkins**

## **1️⃣ Connect to the EC2 Instance**
```bash
ssh -i <your-key.pem> ubuntu@<jenkins-server-public-ip>
```

## **2️⃣ Install Jenkins**
Run the following commands:
```bash
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update && sudo apt install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
```

## **3️⃣ Verify Jenkins Installation**
```bash
sudo systemctl status jenkins
```
Ensure it is **active (running)**.

## **4️⃣ Access Jenkins Web Interface**
Retrieve **admin password**:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
Login at:
```
http://<jenkins-server-public-ip>:8080
```
- Install **suggested plugins**.
- Create an **admin account**.

✅ **Jenkins is now ready!**

# **🐳 Step 3: Installing and Configuring Docker**

## **1️⃣ Install Docker**
```bash
sudo apt update
sudo apt install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

## **2️⃣ Add User to Docker Group**
```bash
sudo usermod -aG docker ubuntu
```
(Re-login for changes to take effect.)

## **3️⃣ Verify Installation**
```bash
docker run hello-world
```
Expected output: `Hello from Docker!`

# **🔍 Step 4: Installing and Configuring SonarQube**
## **1️⃣ Install Java**
```bash
sudo apt install openjdk-17-jre -y
java -version
```

## **2️⃣ Install SonarQube**
```bash
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.2.0.102705.zip
sudo apt install unzip -y
unzip sonarqube-10.2.0.102705.zip
cd sonarqube-10.2.0.102705/bin/linux-x86-64/
```

## **3️⃣ Start SonarQube**
```bash
./sonar.sh console
```
Ensure **TCP port 9000** is open.

## **4️⃣ Access SonarQube Web UI**
```
http://<sonarqube-server-public-ip>:9000
```
- **Username:** `admin`
- **Password:** `admin` (change after login)

✅ **SonarQube is now set up!**

# **🔗 Step 5: Configuring GitHub Webhook for Jenkins**
## **1️⃣ Add Webhook in GitHub**
- Go to **GitHub → Your Repository → Settings → Webhooks**.
- Click **"Add webhook"**.
- **Payload URL**:  
  ```
  http://<jenkins-server-public-ip>:8080/github-webhook/
  ```
- **Content Type**: `application/json`
- Select **"Just the push event"**.
- Click **Add Webhook**.

## **2️⃣ Enable GitHub Webhook Trigger in Jenkins**
- In Jenkins job:
  - Go to **Configure**.
  - Enable **"GitHub hook trigger for GITScm polling"**.
  - Save.

✅ **GitHub Webhook is now integrated!**

# **🔍 Step 6: Integrating SonarQube with Jenkins Pipeline**
## **1️⃣ Install SonarQube Scanner Plugin**
- Go to **Manage Jenkins → Plugin Manager**.
- Install **"SonarQube Scanner"**.
- Restart Jenkins.

## **2️⃣ Configure SonarQube in Jenkins**
- Go to **Manage Jenkins → Configure System**.
- Add:
  - **Name**: `SonarQube`
  - **Server URL**: `http://<sonarqube-server-public-ip>:9000`
  - **Authentication Token**: *(Generated from SonarQube → My Account → Security → Tokens)*.
- Save.

## **3️⃣ Add SonarQube Token in Jenkins Credentials**
- Go to **Manage Jenkins → Manage Credentials**.
- Add a **Secret Text Credential**:
  - **ID**: `SONAR_TOKEN`
  - **Secret**: *(Your SonarQube Token)*.

## **4️⃣ Configure Jenkinsfile**
Add the following to your repository’s `Jenkinsfile`:
```groovy
pipeline {
    agent any
    environment {
        SONAR_URL = 'http://<sonarqube-server-ip>:9000'
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-repo>.git'
            }
        }
        stage('Build') {
            steps {
                //
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar -Dsonar.projectKey=<your-project-key> -Dsonar.host.url=$SONAR_URL -Dsonar.login=$SONAR_TOKEN'
                }
            }
        }
    }
}
```
Push changes to GitHub:
```bash
git add .
git commit -m "Integrated SonarQube with Jenkins Pipeline"
git push origin main
```

<img width="658" alt="Screenshot 2025-02-05 at 1 51 54 PM" src="https://github.com/user-attachments/assets/dddea35b-483d-4900-acea-0162ddbd42cc" />

✅ **SonarQube is now integrated with Jenkins!**

# **🎯 Final Verification**
✅ Jenkins job triggers on GitHub push.  
✅ SonarQube runs static analysis.  
✅ Docker deploys the application.

<img width="560" alt="Screenshot 2025-02-05 at 1 51 29 PM" src="https://github.com/user-attachments/assets/213ecc53-e692-42bc-8c89-2b62d9793921" />


🚀 **CI/CD Pipeline with Jenkins, SonarQube, and Docker is successfully implemented!** 🎉
