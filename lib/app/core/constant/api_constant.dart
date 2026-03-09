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

  static String saveMediaHouse =
      '${baseUrl}userNew/saveMediaHouseWithDirectorCEO/newUser';
  static String editMediaHouseById = "${baseUrl}api/MediaHouse/Update";
  static String getAllMediaHouse = "${baseUrl}api/MediaHouse/getAll";
  static String getMediaHouseByUserId(id) =>
      "${baseUrl}api/MediaHouse/getByUserId?userId=$id";
  static String deleteMediaHouseById(id) =>
      "${baseUrl}api/deleteMediaHouseBy/$id";
  static String searchMediaHouse(char) =>
      "${baseUrl}api/searchByanyKey?search=$char";
  static String getMediaHouseByStatus(status) =>
      "${baseUrl}api/MediaHouse/getByStatus?status=$status";
  static String changeMediaHouseStatus(status, id) =>
      "${baseUrl}api/ApproveMediaHouseBy?mediaHouseId=$id&status=$status";
  static String getMediaHouseDashboardCount(id) =>
      "${baseUrl}api/admin/mediaHouseDashboardApi?mediaHouseId=$id";

  static String saveVideo = '${baseUrl}api/addContent';
  static String saveCast = '${baseUrl}api/saveCast';
  static String getCastByContentId(int contentId) =>
      "${baseUrl}api/Cast/getByContentId?contentId=$contentId";
  static String editVideoById(id) => "${baseUrl}api/contentList/update/$id";
  static String getAllVideo = "${baseUrl}api/ContentList/getAll";
  static String getVideoById(id) => "${baseUrl}api/ContentList/getById?id=$id";
  static String getRatingReviewByContentId(int id) =>
      "${baseUrl}api/content/$id";
  static String getVideoByMediaHouseId(
    id, {
    String type = "MOVIE",
    String? searchKeyword,
    int page = 0,
    int size = 10,
  }) =>
      "${baseUrl}api/content/byMediaHouseAndType/pages?mediaHouseId=$id&type=$type&keyword=${searchKeyword ?? ''}&page=$page&size=$size";
  static String searchContent(char) =>
      "${baseUrl}api/searchByanyKey?search=$char";
  static String deleteVideoById(id) => "${baseUrl}api/deleteContentBy/$id";
  static String getVideoByStatusAndMediaHouse(
    status,
    id, {
    String? searchKeyword,
    int page = 0,
    int size = 10,
  }) =>
      "${baseUrl}api/Approvalstatus/mediahouseid2?approvalStatus=$status&mediaHouseId=$id&keyword=${searchKeyword ?? ''}&page=$page&size=$size";
  static String changeContentStatus(status, id) =>
      "${baseUrl}api/ApprovecontentListBy?contentListId=$id&status=$status";
  static String getReleaseVideoByMediaHouse(id,
          {int page = 0, int size = 10, String? searchKeyword}) =>
      "${baseUrl}api/getReleaseContentByMediahouseId?mediaHouseId=$id&keyword=$searchKeyword&page=$page&size=$size";

  static String filterAdvancedContent({
    required int mediaHouseId,
    required String type,
    required String approvalStatus,
    String? startDate,
    String? endDate,
    String? searchKeyword,
    int page = 0,
    int size = 10,
  }) {
    final params = <String, String>{
      'mediaHouseId': '$mediaHouseId',
      'type': type,
      'approvalStatus': approvalStatus,
      'keyword': searchKeyword ?? '',
      'page': '$page',
      'size': '$size',
    };

    if (startDate != null && startDate.trim().isNotEmpty) {
      params['startDate'] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      params['endDate'] = endDate.trim();
    }

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/content/filter-advanced?$query";
  }

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

  static String uploadImg = "${baseUrl}api/other/upload-file";
  static String uploadContentImg =
      "${baseUrl}api/video/upload-thumbnail?videoId=19";
  static String uploadVideo = "${baseUrl}api/video/upload-raw?videoId=19";
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
    id,
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) {
    final params = <String, String>{
      'mediaHouseId': '$id',
      'startDate': '$startDate',
      'endDate': '$endDate',
      'isYear': '$isYear',
      'isMonth': '$isMonth',
      'isWeek': '$isWeek',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/mediaHouseLineCharts/top-revenue-content-by-media-house?$query";
  }

  static String topRatedContentGraph(
    id,
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) {
    final params = <String, String>{
      'mediaHouseId': '$id',
      'startDate': '$startDate',
      'endDate': '$endDate',
      'isYear': '$isYear',
      'isMonth': '$isMonth',
      'isWeek': '$isWeek',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/mediaHouseLineCharts/top-rated-content-by-media-house?$query";
  }

  static String contentRevenueGraph(
    id,
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) {
    final params = <String, String>{
      'contentListId': '$id',
      'startDate': '$startDate',
      'endDate': '$endDate',
      'isYear': '$isYear',
      'isMonth': '$isMonth',
      'isWeek': '$isWeek',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/contentList/graph?$query";
  }

  static String setPercentage = "${baseUrl}api/admin/saveMoviePercentAndRate";
  static String reportAndData(
    id, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
    String? startDate,
    String? endDate,
  }) {
    final params = <String, String>{
      'id': '$id',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);
    putIfNotBlank('startDate', startDate);
    putIfNotBlank('endDate', endDate);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/reportAndDataMediaHouse/getById?$query";
  }

  static String releaseMovieCountGraphByMediaHouse(
    id,
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) {
    final params = <String, String>{
      'mediaHouseid': '$id',
      'startDate': '$startDate',
      'endDate': '$endDate',
      'isYear': '$isYear',
      'isMonth': '$isMonth',
      'isWeek': '$isWeek',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/mediaHouseLineCharts/releaseMovieCountChart?$query";
  }

  static String viewCountGraphByMediaHouse(
    id,
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) {
    final params = <String, String>{
      'mediahouseId': '$id',
      'startDate': '$startDate',
      'endDate': '$endDate',
      'isYear': '$isYear',
      'isMonth': '$isMonth',
      'isWeek': '$isWeek',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/viewCountChartByMediaHouseId?$query";
  }

  static String revenueGraphByMediaHouse(
    id,
    startDate,
    endDate,
    isYear,
    isMonth,
    isWeek, {
    String? contentType,
    String? country,
    String? state,
    String? district,
    String? taluka,
    String? city,
  }) {
    final params = <String, String>{
      'mediaHouseId': '$id',
      'startDate': '$startDate',
      'endDate': '$endDate',
      'isYear': '$isYear',
      'isMonth': '$isMonth',
      'isWeek': '$isWeek',
    };

    void putIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        params[key] = value.trim();
      }
    }

    putIfNotBlank('contentType', contentType);
    putIfNotBlank('country', country);
    putIfNotBlank('state', state);
    putIfNotBlank('district', district);
    putIfNotBlank('taluka', taluka);
    putIfNotBlank('city', city);

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return "${baseUrl}api/transactionDashboard/mediaHouse/graph?$query";
  }

  //shorts
  static String shortsMaster(
    id, {
    String keyword = '',
    int page = 0,
    int size = 10,
  }) =>
      "${baseUrl}api/shortsMaster/by-mediahouse/$id?keyword=${Uri.encodeQueryComponent(keyword)}&page=$page&size=$size";
  static String shortsTrending({
    String? lang,
    int page = 0,
    int size = 10,
  }) {
    final params = <String, String>{
      "page": "$page",
      "size": "$size",
    };
    if (lang != null && lang.trim().isNotEmpty) {
      params["lang"] = lang.trim();
    }
    final query = params.entries
        .map((e) => "${e.key}=${Uri.encodeQueryComponent(e.value)}")
        .join("&");
    return "${baseUrl}api/shortsMaster/trending?$query";
  }

  static String filterShorts({
    required int mediaHouseId,
    String? startDate,
    String? endDate,
    int page = 0,
    int size = 10,
  }) {
    final params = <String, String>{
      "mediaHouseId": "$mediaHouseId",
      "page": "$page",
      "size": "$size",
    };
    if (startDate != null && startDate.trim().isNotEmpty) {
      params["startDate"] = startDate.trim();
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      params["endDate"] = endDate.trim();
    }
    final query = params.entries
        .map((e) => "${e.key}=${Uri.encodeQueryComponent(e.value)}")
        .join("&");
    return "${baseUrl}api/shortsMaster/shorts/filter?$query";
  }

  static String shortsDetails(id, userId) =>
      "${baseUrl}api/shortsMaster/$id?userId=$userId";
  static String addShortMaster = '${baseUrl}api/shortsMaster';
  static const deleteShortMaster = "${baseUrl}api/shortsMaster";
  static const updateShortMaster = "${baseUrl}api/shortsMaster";

  static String createShortPart = "${baseUrl}api/short-parts";

  static deletePart(partId) => "${baseUrl}api/short-parts/$partId";

  static String saveSeries = '${baseUrl}series/createSeries';
  static String seriesDetails(seriesId) => "${baseUrl}series/$seriesId/details";
  static String getSeriesByMediaHouse(id) =>
      "${baseUrl}api/content/byMediaHouseAndType/pages?mediaHouseId=$id&type=SERIES";
}
