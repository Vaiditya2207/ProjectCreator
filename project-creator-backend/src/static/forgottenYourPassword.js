const template = () => {
    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ProjectCreator - Reset Password</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css" rel="stylesheet">
    <style>
        .progress-step {
            width: 2rem;
            height: 2rem;
            border-radius: 50%;
            background-color: #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }
        
        .progress-step.active {
            background-color: #3b82f6;
            color: white;
        }
        
        .progress-step::after {
            content: '';
            position: absolute;
            width: 100%;
            height: 2px;
            background-color: #e5e7eb;
            right: -100%;
            top: 50%;
            transform: translateY(-50%);
        }
        
        .progress-step:last-child::after {
            display: none;
        }
        
        .progress-step.completed {
            background-color: #10b981;
            color: white;
        }
        
        .progress-step.completed::after {
            background-color: #10b981;
        }

        .error-message {
            animation: fadeIn 0.3s ease-in;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body class="bg-gray-50 min-h-screen">
    <!-- Header -->
    <nav class="bg-white shadow-sm">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16">
                <div class="flex-shrink-0 flex items-center">
                    <span class="text-2xl font-bold text-blue-600">ProjectCreator</span>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="max-w-lg mx-auto mt-10 bg-white rounded-lg shadow-md p-8">
        <div class="text-center mb-8">
            <h1 class="text-2xl font-bold text-gray-900">Reset Your Password</h1>
            <p class="mt-2 text-sm text-gray-600">Follow the steps below to reset your password securely</p>
        </div>

        <!-- Error Message Container -->
        <div id="errorContainer" class="hidden mb-4">
            <div class="bg-red-50 border-l-4 border-red-500 p-4 error-message">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <svg class="h-5 w-5 text-red-500" viewBox="0 0 20 20" fill="currentColor">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/>
                        </svg>
                    </div>
                    <div class="ml-3">
                        <p id="errorText" class="text-sm text-red-700"></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Timer Display -->
        <div id="timerDisplay" class="hidden text-center mb-4">
            <p class="text-sm text-gray-600">Time remaining: <span id="timer" class="font-medium text-blue-600">5:00</span></p>
        </div>

        <!-- Progress Steps -->
        <div class="flex justify-between mb-8 relative">
            <div class="progress-step active" id="step1">1</div>
            <div class="progress-step" id="step2">2</div>
            <div class="progress-step" id="step3">3</div>
        </div>

        <!-- Email Form -->
        <form id="emailForm" class="space-y-6">
            <div>
                <label for="email" class="block text-sm font-medium text-gray-700">Email address</label>
                <input type="email" id="email" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Enter your email">
            </div>
            <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                Send OTP
            </button>
        </form>

        <!-- OTP Form -->
        <form id="otpForm" class="hidden space-y-6">
            <div>
                <label for="otp" class="block text-sm font-medium text-gray-700">Enter OTP</label>
                <input type="text" id="otp" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Enter 6-digit OTP">
                <p class="mt-2 text-sm text-gray-500">Please check your email for the OTP</p>
            </div>
            <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                Verify OTP
            </button>
        </form>

        <!-- Password Form -->
        <form id="passwordForm" class="hidden space-y-6">
            <div>
                <label for="newPassword" class="block text-sm font-medium text-gray-700">New Password</label>
                <input type="password" id="newPassword" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Enter new password">
            </div>
            <div>
                <label for="confirmPassword" class="block text-sm font-medium text-gray-700">Confirm Password</label>
                <input type="password" id="confirmPassword" required class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500 sm:text-sm" placeholder="Confirm new password">
            </div>
            <button type="submit" class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                Reset Password
            </button>
        </form>
    </div>

    <!-- Powered by -->
    <div class="fixed bottom-4 right-4 text-sm text-gray-500">
        Powered by CodeMelon
    </div>

    <script>
        let timeoutId;
        let timerId;

        function showError(message) {
            const errorContainer = document.getElementById('errorContainer');
            const errorText = document.getElementById('errorText');
            errorText.textContent = message;
            errorContainer.classList.remove('hidden');
            setTimeout(() => {
                errorContainer.classList.add('hidden');
            }, 5000); // Hide error after 5 seconds
        }

        function startTimer(duration) {
            const timerDisplay = document.getElementById('timerDisplay');
            const timerElement = document.getElementById('timer');
            timerDisplay.classList.remove('hidden');
            
            let timer = duration;
            timerId = setInterval(() => {
                const minutes = parseInt(timer / 60, 10);
                const seconds = parseInt(timer % 60, 10);

                timerElement.textContent = minutes + ":" + (seconds < 10 ? "0" : "") + seconds;

                if (--timer < 0) {
                    clearInterval(timerId);
                    location.reload();
                }
            }, 1000);
        }

        function exitPage() {
            window.close();
        }

        document.getElementById('emailForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const checkResponse = await fetch('http://localhost:8000/api/check-user', {

            
            if (checkResponse.status === 200) {
                // User exists, proceed to send OTP
                const response = await fetch('https://mailservice-production-22aa.up.railway.app/api/projectcreator/otp', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json', Authorization: "somethingverysecret"},
                    body: JSON.stringify([{
                        to: email,
                        subject: 'One Time Password',
                        body: 'Your OTP is:',
                        username: 'user',
                        digit: 6
                    }])
                });
                const data = await response.json();
                if(data.message === "Email sent successfully") {
                    sessionStorage.setItem('otp', data.otp);
                    sessionStorage.setItem('otpExpiry', Date.now() + 300000); // 5 minutes
                    document.getElementById('emailForm').classList.add('hidden');
                    document.getElementById('otpForm').classList.remove('hidden');
                    document.getElementById('step1').classList.add('completed');
                    document.getElementById('step2').classList.add('active');
                    
                    // Start 5-minute timer
                    startTimer(300);
                    
                    // Set page reload timeout
                    timeoutId = setTimeout(() => {
                        location.reload();
                    }, 300000); // 5 minutes
                } else {
                    showError('Failed to send OTP. Please try again.');
                    sendOtpButton.disabled = false; // Re-enable on failure
                }
            } else {
                // User does not exist
                showError('Not valid email');
                sendOtpButton.disabled = false; // Re-enable on failure
            }
        });

        document.getElementById('otpForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const enteredOtp = document.getElementById('otp').value;
            const storedOtp = sessionStorage.getItem('otp');
            const otpExpiry = sessionStorage.getItem('otpExpiry');

            if(!storedOtp || !otpExpiry) {
                showError('No OTP found. Please request a new one.');
                return;
            }

            if(Date.now() > otpExpiry) {
                showError('OTP has expired. Please request a new one.');
                return;
            }

            if(enteredOtp === storedOtp) {
                document.getElementById('otpForm').classList.add('hidden');
                document.getElementById('passwordForm').classList.remove('hidden');
                document.getElementById('step2').classList.add('completed');
                document.getElementById('step3').classList.add('active');
                
                // Clear the timer when OTP is verified
                clearInterval(timerId);
                clearTimeout(timeoutId);
                document.getElementById('timerDisplay').classList.add('hidden');
            } else {
                showError('Incorrect OTP. Please try again.');
            }
        });

        document.getElementById('passwordForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            if(newPassword !== confirmPassword) {
                showError('Passwords do not match.');
                return;
            }

            const email = sessionStorage.getItem('email'); // Retrieve stored email

            if(!email) {
                showError('Email not found.');
                return;
            }

            try {
                const response = await fetch('http://localhost:8000/api/afterOtp/change-password', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ email, 'password': newPassword })
                });

                if(response.ok) {
                    document.getElementById('step3').classList.add('completed');
                    
                    // Show success message and exit
                    const successMessage = document.createElement('div');
                    successMessage.className = 'fixed top-0 left-0 w-full h-full flex items-center justify-center bg-black bg-opacity-50';
                    successMessage.innerHTML = \`
                        <div class="bg-white p-8 rounded-lg shadow-xl text-center">
                            <svg class="mx-auto h-12 w-12 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            <h3 class="mt-4 text-lg font-medium text-gray-900">Password Reset Successful!</h3>
                            <p class="mt-2 text-sm text-gray-500">Your password has been successfully reset.</p>
                            <button class="mt-4 w-full inline-flex justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none">
                                Close
                            </button>
                        </div>
                    \`;
                    
                    document.body.appendChild(successMessage);
                    
                    // Exit page after 2 seconds
                    setTimeout(exitPage, 2000);
                } else {
                    showError('Failed to change password. Please try again.');
                }
            } catch (error) {
                showError('An error occurred. Please try again.');
            }
        });
    </script>
</body>
</html>`
}


export default template;