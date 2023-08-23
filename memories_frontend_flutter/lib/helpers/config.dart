const String imageLogoPath = 'assets/images/logo/';
const isProduction = false;
const baseURL = isProduction ? 'https://memories.panera.mg/' : 'http://192.168.205.2:8000/';
const storage = '${baseURL}storage/';
const baseURLAPI = '${baseURL}api/';
const loginURL = '${baseURLAPI}login';
const registerURL = '${baseURLAPI}register';
const logoutURL = '${baseURLAPI}logout';
const userURL = '${baseURLAPI}user';
const postsURL = '${baseURLAPI}posts';
const commentsURL = '${baseURLAPI}comments';
const searchURL = '${baseURLAPI}search';

// ----- Errors -----
const serverError = 'Server error';
const unauthorized = 'Unauthorized';
const somethingWentWrong = 'Something went wrong, try again!';


