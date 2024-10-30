# ProjectCreator
* Project Creator is a openSource native mac app build on top of Apple's New Ui FrameWork **SWIFTUI**.
* Main Purpose of this app is to help College students save time and thinking to think the structure of their apps as it will provide them well structured Templates to use and it is *free of cost*.
* This Guide will give you all steps how to use the app.


## About the App
* **TechStack**: SwiftUI, Node Js
* **MacOS Version**: Available on MacOS 14.0 and Newer (Both Intel and Apple Silicon)
* **Current Version**: Aplha-Version0.0.2
* **FeedBacks**: You are welcome to give your valuable feedback at feedback.projectcreator@codemelon.xyz
* **DownloadLinks**: You can download the latest version from https://projectcreator.onrender.com/api/download/latest Or You can download previous version from https://projectcreator.onrender.com/api/download/archives

## Prerelease Installation Steps
Since this is a prerelease version of the app and isn't yet signed, please follow these steps to install it:

### Step 1: Disable Gatekeeper
1. Open **Terminal**.
2. Run the following command to disable Gatekeeper:
   ```bash
   sudo spctl --master-disable
   ```

3. Go to **System Settings > Privacy & Security**.
4. Under **Allow apps downloaded from**, select **Anywhere**.

*Note: This step is only necessary for unsigned apps.*

## Step 2: Install the App
1. Download the .dmg file from https://projectcreator.onrender.com/api/download/latest.
2. Open the .dmg file.
3. Copy the app to your **Applications** folder.

## Step 3: Run the App
1. Go to the **Applications** folder.
2. Right-click the app icon and select **Open**. (This is required to bypass macOS security warnings for the first launch.)

*After following these steps, Gatekeeper can be re-enabled with:*
```bash
sudo spctl --master-enable
```

* **Create Your Own Templates**: Design custom templates tailored to your projects, stored securely in the cloud for easy access.
* **Instant Project Creation**: Choose a template and, with a single click, create a new project, saving you setup time.
* **User Accounts**: Create an account to personalize your experience, manage your templates, and access cloud storage.

Thank you for trying this prerelease version! Your feedback is invaluable to making the app even better.


# Instruction to host the app yourself

## Setup Backend

### Step 1: Clone the App
You can clone the app by Forking this repo and then cloning it or you can simply download the zip file of the code

### Step 2: Setting up Environment Variables
Taking the reference from the example.env you can create an ENV file with your tokens to make it Customizable

### Step 3: Host the backend
You have you now host the backend.
Popular Options to Host Backend are
1. AWS
2. Heroku
3. Azure
4. Render
5. Railway

Now your Backend is good to go you can test the api yourself using the postman

## Setup the Frontend

### Step 1: Setting up Environment Variables
You have to change the domain name of the api in the Environment Variables of the Swift Application

### Step 2: Customization (Optional Step)
You can customize the app however you want and however you like then just Archive the app and Sign it using Apple Developer ID


# Rules and Regulations to use the App

* **Usage**: Can be used by anyone and they can change whatever they want.
* **Distribution**: To distribute the app, you must obtain permission from the original author. Please contact the author at [admin.projectcreator@codemelon.xyz](mailto:admin.projectcreator@codemelon.xyz) for distribution rights.