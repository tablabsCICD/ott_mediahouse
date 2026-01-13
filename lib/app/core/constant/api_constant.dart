class ApiConstant {
  static const String baseUrl =
      "http://ec2-13-201-5-93.ap-south-1.compute.amazonaws.com:8080/ott/";

  static String login(mobileNumber) =>
      "${baseUrl}user/forgotPassword/findUserAndSendOTP?mobileNumber=$mobileNumber";
  static String verifyOtp(mobileNumber, otp) =>
      "${baseUrl}user/verifyOTP?mobileNumber=$mobileNumber&otp=$otp";
  static String registration = '${baseUrl}user/RegisterUser';
  static String getAllUser = "${baseUrl}user/getAllActiveUsers";
  static String editUserById = "${baseUrl}user/updateUserBy/%7Bid%7D";
  static String getUserById(id) => "${baseUrl}user/getUser/$id";
  static String deleteUserById(id) => "${baseUrl}user/deleteUserBy/$id";
  static String searchUser(char) => "${baseUrl}user/search?search=$char";

  static String saveMediaHouse = '${baseUrl}api/saveMediaHouse';
  static String editMediaHouseById = "${baseUrl}api/MediaHouse/Update";
  static String getAllMediaHouse = "${baseUrl}api/MediaHouse/getAll";
  static String getMediaHouseByUserId(id) =>
      "${baseUrl}api/MediaHouse/getByUserId?userId=$id";
  static String deleteMediaHouseById(id) =>
      "${baseUrl}api/deleteMediaHouseBy/$id";
  static String searchMediaHouse(char) =>
      "${baseUrl}api/searchByanyKey%20?search=$char";
  static String getMediaHouseByStatus(status) =>
      "${baseUrl}api/MediaHouse/getByStatus?status=$status";
  static String changeMediaHouseStatus(status, id) =>
      "${baseUrl}api/ApproveMediaHouseBy?mediaHouseId=$id&status=$status";
  static String getMediaHouseDashboardCount(id) =>
      "${baseUrl}api/admin/mediaHouseDashboardApi?mediaHouseId=$id";

  static String saveVideo = '${baseUrl}api/addContent';
  static String editVideoById(id) => "${baseUrl}api/contentList/update/$id";
  static String getAllVideo = "${baseUrl}api/ContentList/getAll";
  static String getVideoById(id) => "${baseUrl}api/ContentList/getById?id=$id";
  static String getVideoByMediaHouseId(id) =>
      "${baseUrl}api/content/byMediaHouse?mediaHouseId=$id";
  static String searchContent(char) =>
      "${baseUrl}api/searchByanyKey%20?search=$char";
  static String deleteVideoById(id) => "${baseUrl}api/deleteContentBy/$id";
  static String getVideoByStatusAndMediaHouse(status, id) =>
      "${baseUrl}api/Approvalstatus/mediahouseid2?approvalStatus=$status&mediaHouseId=$id";
  static String changeContentStatus(status, id) =>
      "${baseUrl}api/ApprovecontentListBy?contentListId=$id&status=$status";
  static String getReleaseVideoByMediaHouse(id) =>
      "${baseUrl}api/getReleaseContentByMediahouseId%20?mediaHouseId=$id";

  static String savePromoter = '${baseUrl}api/savePromoters2';
  static String editPromoterById = "${baseUrl}user/updateUserBy/%7Bid%7D";
  static String getAllPromoter = "${baseUrl}api/Promoters/getAll";
  static String getPromoterById(id) => "${baseUrl}user/getUser/$id";
  static String deletePromoterById(id) => "${baseUrl}api/deletePromotersBy/$id";
  static String getPromoterByStatus(status) =>
      "${baseUrl}api/Promoters/getByStatus?status=$status";
  static String changePromoterStatus(status, id) =>
      "${baseUrl}api/ApprovecontentListBy?contentListId=$id&status=$status";
  static String getUsersByPromoterCode(code) =>
      "${baseUrl}user/getUsersByPromoterReferralCode2?refferedBy=$code";
  static String getPromotersByPromoterCode(code) =>
      "${baseUrl}user/getPromotersByPromoterReferralCode2?refferedBy=$code";
  static String getUserAndRevenueGraph(startDate, endEnd, promoterId) =>
      "${baseUrl}api/admin/userOnboardedGraphByPromoterId2?start_date=$startDate&end_date=$endEnd&promoterId=$promoterId";

  static String uploadImg = "${baseUrl}api/saveImage/new";
  static String uploadVideo = "${baseUrl}api/encrypturl/saveVideo/new";
  static String dashboardCount = "${baseUrl}api/admin/dashboardCounts";

  static String resetPassword(mobile, password) =>
      "${baseUrl}user/resetPassword?mobileNumber=$mobile&password=$password";
  static String forgotPassword(mobile) =>
      "${baseUrl}user/forgotPassword/findUserAndSendOTP?mobileNumber=$mobile";

  static String raiseTicket = "${baseUrl}api/TicketRaised/add";
  static String deleteTicket(id) =>
      "${baseUrl}api/TicketRaised/deleteTicketRaisedBy/$id";
  static String updateTicket(id) => "${baseUrl}api/TicketRaised/update/$id";
  static String getRaisedTicket =
      "${baseUrl}api/TicketRaised/getAllTicketRaised";
  static String getRaisedTicketByUserId(userId) =>
      "${baseUrl}api/TicketRaised/user/$userId";
  static String getRaisedTicketByFlag(isResolved) =>
      "${baseUrl}api/TicketRaised/getTicketRaisedForAdmin?isResolved=$isResolved";

  static String weeklySettelementData(id) =>
      "${baseUrl}api/settelment/user/$id";

  static String topRevenueContentGraph(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String topRatedContentGraph(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/mediaHouseLineCharts/top-rated-content-by-media-house?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";

  static String contentRevenueGraph(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/contentList/graph?contentListId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";

  static String setPercentage = "${baseUrl}api/admin/saveMoviePercentAndRate";
  static String reportAndData(id) =>
      "${baseUrl}api/mediaHouseLineCharts/getDetailsOfMovieByMediaHouseId?mediaHouseId=$id";

  static String releaseMovieCountGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/mediaHouseLineCharts/releaseMovieCountChart?mediaHouseid=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String viewCountGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/viewCountChartByMediaHouseId?mediahouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";
  static String revenueGraphByMediaHouse(
          id, startDate, endDate, isYear, isMonth, isWeek) =>
      "${baseUrl}api/transactionDashboard/mediaHouse/graph?mediaHouseId=$id&startDate=$startDate&endDate=$endDate&isYear=$isYear&isMonth=$isMonth&isWeek=$isWeek";

  //shorts
  static String shortsMaster = "${baseUrl}api/shortsMaster";
  static String shortsDetails(id, userId) =>
      "${baseUrl}api/shortsMaster/$id?userId=$userId";
  static String addShortMaster = '${baseUrl}api/shortsMaster';
}
