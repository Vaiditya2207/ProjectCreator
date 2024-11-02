const template = () => {
    return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ProjectCreator - Verification Successful</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/tailwindcss/2.2.19/tailwind.min.css" rel="stylesheet">
    <style>
        .success-message {
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
    <div class="max-w-lg mx-auto mt-20 bg-white rounded-lg shadow-md p-8">
        <div class="text-center">
            <svg class="mx-auto h-12 w-12 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <h1 class="mt-4 text-2xl font-bold text-gray-900">Verification Successful</h1>
            <p class="mt-2 text-gray-600">
                Your account has been successfully verified. Please logout and login again to continue as a Verified User.
            </p>
            <button onclick="window.close()" class="mt-6 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
                Close Page
            </button>
        </div>
    </div>

    <!-- Powered by -->
    <div class="fixed bottom-4 right-4 text-sm text-gray-500">
        Powered by CodeMelon
    </div>
</body>
</html>`;
}

export default template;