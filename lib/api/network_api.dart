import 'package:apple_user/model/account_delete_model.dart';

import '../model/appointments_model.dart';
import '../model/banner_model.dart';
import '../model/common_response.dart';
import '../model/detail_setting_model.dart';
import '../model/display_offer_model.dart';
import '../model/favorite_doctor_model.dart';
import '../model/forgot_password_model.dart';
import '../model/health_tip_model.dart';
import '../model/healtht_tip_detail_model.dart';
import 'package:apple_user/model/medicine_order_detail_model.dart';
import 'package:apple_user/model/medicine_order_model_model.dart';
import 'package:apple_user/model/medicine_details_model.dart';
import 'package:apple_user/model/notification_model.dart';
import 'package:apple_user/model/Pharamacies_details_model.dart';
import 'package:apple_user/model/resend_otp_model.dart';
import 'package:apple_user/model/review_model.dart';
import 'package:apple_user/model/show_address_model.dart';
import 'package:apple_user/model/show_favorite_doctor_model.dart';
import 'package:apple_user/model/time_slot_model.dart';
import 'package:apple_user/model/treatment_wish_doctor_model.dart';
import 'package:apple_user/model/treatments_model.dart';
import 'package:apple_user/model/update_profile_model.dart';
import 'package:apple_user/model/update_user_image_model.dart';
import 'package:apple_user/model/user_detail_model.dart';
import 'package:apple_user/model/apply_offer_model.dart';
import 'package:apple_user/model/doctor_detail_model.dart';
import 'package:apple_user/model/pharamacies_model.dart';
import 'package:apple_user/model/prescription_model.dart';
import 'package:apple_user/model/register_model.dart';
import 'package:apple_user/model/show_video_call_history_model.dart';
import 'package:apple_user/model/video_call_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:apple_user/model/login_model.dart';
import 'package:dio/dio.dart';
import 'package:apple_user/model/doctors_model.dart';
import 'package:apple_user/model/book_appointments_model.dart';
import 'package:apple_user/model/check_otp_model.dart';
import 'package:retrofit/http.dart';

import 'apis.dart';

part 'network_api.g.dart';

@RestApi(baseUrl: Apis.baseUrl)
abstract class RestClient {
  factory RestClient(Dio dio, {String? baseUrl}) = _RestClient;

  @POST(Apis.login)
  Future<Login> loginRequest(@Body() body);

  @POST(Apis.register)
  Future<Register> registerRequest(@Body() body);

  @POST(Apis.doctors_list)
  Future<Doctors> doctorList(@Body() body);

  @POST(Apis.doctor_detail)
  Future<DoctorDetailModel> doctorDetailRequest(@Path() int? id, @Body() body);

  @GET(Apis.healthTip)
  Future<HealthTip> healthTipRequest();

  @GET(Apis.healthTip_detail)
  Future<HealthTipDetails> healthTipDetailRequest(@Path() int? id);

  @GET(Apis.treatment_list)
  Future<Treatments> treatmentsRequest();

  @GET(Apis.book_appointment_list)
  Future<Appointments> appointmentsRequest();

  @GET(Apis.medicine_detail)
  Future<MedicineDetails> medicineDetails(@Path() int? id);

  @POST(Apis.user_book_appointment)
  Future<BookAppointments> bookAppointment(@Body() body);

  @POST(Apis.check_otp)
  Future<Checkotp> checkOtp(@Body() body);

  @POST(Apis.timeSlot)
  Future<Timeslot> timeslot(@Body() body);

  @POST(Apis.add_address)
  Future<CommonResponse> addAddressRequest(@Body() body);

  @GET(Apis.show_address)
  Future<ShowAddress> showAddressRequest();

  @GET(Apis.delete_address)
  Future<CommonResponse> deleteAddressRequest(@Path() int? id);

  @GET(Apis.user_detail)
  Future<UserDetail> userDetailRequest();

  @GET(Apis.setting)
  Future<DetailSetting> settingRequest();

  @GET(Apis.all_pharamacy)
  Future<Pharamacy> pharamacyRequest();

  @GET(Apis.pharamacy_detail)
  Future<PharamaciesDetails> pharmacyDetailRequest(@Path() int? id);

  @POST(Apis.book_medicine)
  Future<CommonResponse> bookMedicineRequest(@Body() body);

  @POST(Apis.add_review)
  Future<ReviewAppointment> addReviewRequest(@Body() body);

  @POST(Apis.cancel_appointment)
  Future<CommonResponse> cancelAppointmentRequest(@Body() body);

  @GET(Apis.medicine_order_list)
  Future<MedicineOrderModel> medicineOrderRequest();

  @POST(Apis.update_profile)
  Future<UpdateProfile> updateProfileRequest(@Body() body);

  @GET(Apis.medicine_order_detail)
  Future<MedicineOrderDetails> medicineOrderDetailRequest(@Path() int? id);

  @GET(Apis.offer)
  Future<DisplayOffer> displayOfferRequest();

  @POST(Apis.treatmentWise_doctor)
  Future<TreatmentWishDoctor> treatmentWishDoctorRequest(@Path() int? id, @Body() body);

  @POST(Apis.update_image)
  Future<UpdateUserImage> updateUserImageRequest(@Body() body);

  @GET(Apis.user_notification)
  Future<UserNotification> notificationRequest();

  @GET(Apis.banner)
  Future<Banners> bannerRequest();

  @GET(Apis.add_favorite_doctor)
  Future<FavoriteDoctor> favoriteDoctorRequest(@Path() int? id);

  @GET(Apis.show_favorite_doctor)
  Future<ShowFavoriteDoctor> showFavoriteDoctorRequest();

  @POST(Apis.forgot_password)
  Future<ForgotPassword> forgotPasswordRequest(@Body() body);

  @POST(Apis.apply_offer)
  Future<ApplyOffer> applyOfferRequest(@Body() body);

  @POST(Apis.change_password)
  Future<CommonResponse> changePasswordRequest(@Body() body);

  @GET(Apis.resend_otp)
  Future<ResendOtp> resendOtpRequest(@Path() int? id);

  @GET(Apis.prescription)
  Future<PrescriptionModel> prescriptionRequest(@Path() int? id);

  @POST(Apis.videoCallToken)
  Future<VideoCallModel> videoCallRequest(@Body() body);

  @GET(Apis.ShowVideoCallHistory)
  Future<ShowVideoCallHistoryModel> showVideoCallHistoryRequest();

  @GET(Apis.deleteAccount)
  Future<AccountDeleteModel> deleteAccount();
}
