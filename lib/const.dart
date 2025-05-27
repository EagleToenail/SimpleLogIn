const String SERVER_URL = 'http://13.60.93.6:3001/api';
// const String SERVER_URL = 'http://192.168.141.64:3001/api';

const String LOGIN_URL = '$SERVER_URL/user/login';
const String GET_PEOPLE_URL = '$SERVER_URL/user';
const String GET_LOCATIONS_URL = '$SERVER_URL/location';

const String GET_SCHEDULE_URL = '$SERVER_URL/schedule/list';
const String UPDATE_SCHEDULE_URL = '$SERVER_URL/schedule/update';
const String CHECK_SCHEDULE_TODAY_URL =
    '$SERVER_URL/schedule/check_today_shift';

const String GET_SHIFT_LIST_URL = '$SERVER_URL/schedule/user_list';
const String GET_TIMESHEETS_LIST_URL = '$SERVER_URL/schedule/user_timesheets';
const String GET_SWAP_AND_OFFER_LIST_URL =
    '$SERVER_URL/schedule/swap_and_offer_available';
const String CLOCK_SCHEDULE_URL = '$SERVER_URL/schedule/clock_in_out';

const String SET_NOWORK_URL = '$SERVER_URL/schedule/nowork_post';

const String ADD_LEAVE_URL = '$SERVER_URL/leave';
const String GET_LEAVE_URL = '$SERVER_URL/leave/list';
const String UPDATE_LEAVE_URL = '$SERVER_URL/leave';

const String ADD_UNAVAILABLE_URL = '$SERVER_URL/unavailable';
const String GET_UNAVAILABLE_URL = '$SERVER_URL/unavailable/list';

const String ADD_TASK_URL = '$SERVER_URL/task';
const String GET_TASK_URL = '$SERVER_URL/task/list';
const String GET_TASK_COMPLETED_URL = '$SERVER_URL/task/complete';

const String POST_FEED_URL = '$SERVER_URL/newsfeed';
const String GET_FEED_URL = '$SERVER_URL/newsfeed';
const String POST_COMMENT_FEED_URL = '$SERVER_URL/newsfeed/comment';
const String GET_COMMENT_LIST_URL = '$SERVER_URL/newsfeed/list';

const String GET_SERVER_TIME_URL = '$SERVER_URL/user/server_time';
