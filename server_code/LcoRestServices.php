<?php defined('BASEPATH') OR exit('No direct script access allowed');

require APPPATH.'/libraries/REST_Controller.php';
class LcoRestServices extends REST_Controller
{
   
    function __construct()
    {
        parent::__construct();
        $this->serverIp = $_SERVER['SERVER_ADDR'];
        $this->smsurl = "http://".$this->serverIp."/index.php/";  //For Live
        $method_name = $this->router->fetch_method();
        write_to_file("----------------- method name --------- ".$method_name);
        $this->load->library('Encryption_lib');
        $this->load->library('Number_validation_lib');
        $this->load->model('Service_Employee_Login_Model');
        
        // IP restiction check
        $this->iprestriction_check();
        
        // JWT token verification
        if($method_name!='validateLogin')
        {
            $this->checkAuthentication();
        }
        
        if(count($this->post())>0){
            //print_r($this->post());exit;
            write_to_file("-----------------  payload --------- ".json_encode($this->post()));
            write_to_file("-----------------  header --------- ".json_encode(apache_request_headers()));
            $this->payload = $this->encryption_lib->checkPayload($this->post());
           // $jsonString = '{"customerId":175493,"boxNumber":"S54A0F934150026146"}';
           // $this->payload = json_decode($jsonString);
            
            write_to_file("-----------------  payload decrypted --------- ".json_encode($this->payload));
            if($this->payload==''){
                $response=json_encode(array("payload"=>"NA",'hash'=>"NA"));
                $this->response($response, 200); exit;
            }
            if (!is_object($this->payload)) { $this->payload = (object)$this->payload;}
        }
       
       
      
    }
   
    public $lcoEmployeeId;
    public $lcoDealerId;
    public function iprestriction_check(){
        try{
            // IP restiction check
            $arr_status = $this->commonfunctions->ipcheckForRest();
            if(!empty($arr_status))
            {
                    $msg = isset($arr_status['statusMessage'])?$arr_status['statusMessage']:'Invalid access';
                    throw new Exception($msg);
            }
        }
        catch(Exception $e)
        {
            $this->error_res($e, 401);
        }
        
    }
    public function checkAuth()
    {

        $authToken = NULL;
        $verifiedTokenData = $this->getJwtTokenData();
       
        // Change the checking method for $verifiedTokenData(Object data) by ramesh
        if(empty($verifiedTokenData))
        {
                throw new Exception("Key Expired / Invalid URL");
        }
        else
        {
                $authToken  = isset($verifiedTokenData->authtoken)?$verifiedTokenData->authtoken:'';

                $this->setAuthToken($authToken);
        }
        if(empty($authToken))
        {
            throw new Exception("Please Enter Token");
        }
        else{
            
            $this->load->model(array('WsModel'));
            $employeeId = $this->WsModel->isValidPassToken($authToken);
            $this->setLcoEmployeeId($employeeId);
            $dealerId = $this->WsModel->getDealerId($employeeId); // new line added
            $this->setDealerId($dealerId);
            // Code Added by pavan for Parallel login restrction
            $enableParallelLoginLov = $this->WsModel->getLovValue('ENABLE_PARALLEL_LOGIN',$dealerId);
            if($enableParallelLoginLov == 1){
              $this->load->model('EmployeeModel');
              $db_session_id = $this->EmployeeModel->getEmployeeSessionId($employeeId);
              if($db_session_id  != $authToken){
                $employeeId == 0 ;
                $errorMessage = 'Your session has been terminated because you logged in from another device.';
              }
            }
            // End by pavan 
            if($employeeId == 0 || $dealerId == 0)
            {
                throw new Exception("Invalid Token");
            }
        }
    }
    public function checkAuthentication()
    {
        try
        {
            $this->checkAuth();
        }
        catch(Exception $e)
        {

            $this->error_res($e, 401);
        }
    }
    public function setLcoEmployeeId($employeeId=0)
    {
        $this->lcoEmployeeId = $employeeId;
    }
    public function setAuthToken($authToken)
    {
        $this->authToken = $authToken;
    }
    public function setDealerId($dealerId=0)
    {
        $this->lcoDealerId = $dealerId;
    }
    public function getEmployeeId()
    {
        return $this->lcoEmployeeId;
    }
    public function getDealerId()
    {
       return $this->lcoDealerId;
    }
    public function getAuthToken()
    {
       return $this->authToken;
    }

    public function error_res($e,$http_status_code=200)
    {
        $result = array('status_code'=>0, 'status_msg'=>$e->getMessage());
        $this->sendResponse($result, $http_status_code);
    }

public function validateLogin_post(){
    try {
         $statusCode = 1;
        $statusMessage = 'Failed';
            //validations start
        $username = isset($this->payload->UserName) ? $this->payload->UserName : '';
        $password = isset($this->payload->PassWord) ? $this->payload->PassWord : '';
        $mobile_no = isset($this->payload->mobile_no) ? $this->payload->mobile_no : '';
        $imei = isset($this->payload->imei) ? $this->payload->imei : '';
        $validation_fields=['UserName'=>['isString|isRequired','User Name'],'PassWord'=>['isString|isRequired','PassWord'],'mobile_no'=>['isString','Mobile No'],'imei'=>['isString','IMEI']];
        $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

        
        $authToken = '';    //string
        $employeeId = 0;    //integer
        $employeeName = ''; //string
        $useCRF = 0;
        $useCAF = '';
        $useLastName = 0;
        $useDiscount = 0;
        $useDataFromMasterTable = 0;
        $useMandatoryForHotel = 0;
        $useAccountNumber = 0;
        $employeeParentId = '';
        $employeeParentType = '';
        $dealerId = 0;
        $userType = '';
        $useLcoDeposit='';
        $showLcoComplaint='';
        $first_name='';
        $last_name='';
        $address1='';
        $address2='';
        $address3='';
        $pin_code='';
        $phone='';
        $email='';
        $city=0;
        $country ='';
        $state ='';
        $district=0;
        $dob='';
        $adate='';
        $deposit_amount='';
        $copy_rights = '';         
        $short_name = '';         
        $defaultCountry = '';
        $defaultState = '';
        $defaultDistrict = '';
        $defaultCity = '';
        $recurringServiceEdit = '';    
        $appMenuFormat = '';
        $lcoCode = '';            
        $lcoLocation = '';
        $lcoMobileNo = '';
        $invoicepaymentsearchlimit='';
        $lco_billtype ='';
        $use_lco_deposits ='';
        $is_unpaidlco=0;
        $duration = 0;
        $customer_billtype ='';
        $currency=''; //added by Rupendhra
        $show_mia_agreement_upload=0;
        $accept_terms_condtions=1;  
        $agreement_details_count=0;
        $access_distributor_wise=0;
        $freezecustomerparamsinapp=0;
        $blockpayment = 0;
        $business_name='';
        $userNotifications = array();
        $AUTO_RECEIPT_NUMBER=1;
        $patch_information = 0;
        $int_allow_top_up=0;
        $stb_pairing=0;
        $stb_unpairing=0;
        $int_is_direct_lco = 0;
        $jwtToken='';
        $show_serial_vc = 0;
        $base64Image = "";
        $show_service_extension = 0;
        $country_name = "";
        $config_values_array = array();
        $config_values_array['min_mobile_length'] = 10;
        $config_values_array['max_mobile_length'] = 10;
        $config_values_array['pincode_length'] = 6;
        $config_values_array['country_code'] = 91;
        $edit_quantity = 0;
        $enable_box_wise_payment = 0;
        $baid_label="";
        $this->load->model(array('WsModel', 'Notification_model','EmployeeModel','CountryValidationModel'));
        
        $int_show_caf_mobile_validation = 0;
       
			//USERNAME AND PASSWORD VALIDATION
		if($username!='' && $password!='')
		{

                                                //IMEI VALIDATION				
			if($imei != '')
			{	
                                                    $res = $this->WsModel->validateLogin($username,md5($password),$imei,$mobile_no);
                                                }
                                                else{
                                                    $res = $this->WsModel->validateLoginCredentials($username,md5($password),$mobile_no);
                                                }	
                                                
			if(!empty($res))
			{
				$pwdchangereq = isset($res->pwdchangereq)?$res->pwdchangereq:0;
				if($res->status == 0)
				{
					$statusCode = 2;
					$statusMessage = 'User has been DEACTIVATED.';
				}
				else if($pwdchangereq ==1 )
				{
					$statusCode = 2;
					$statusMessage = 'Please login from Web and update the password.';
				}
				else
				{


                                                                                /* Get Login Notifications for LCO - FAYAZ -  22-7-2017 */                                    
                                                                                $is_notified_arr = $this->Notification_model->isNotificationExist($res->employee_id,$res->employee_parent_type,$res->users_type,$show_in_popup=1);

                                                                                $agreement_details_count=$this->WsModel->getmia_agreementdetailsCount($res->employee_id);
                                                                                
                                                                                if (!empty($is_notified_arr)) {
                                                                                    $userNotifications = $is_notified_arr;
                                                                                    $durations = array_map(function($o) {
                                                                                        return $o->duration;
                                                                                    }, $userNotifications);
                                                                                    $duration = max($durations);
                                                                                }
					$statusCode = 0;
					$statusMessage = 'Success';
					$authToken = $res->passtoken;
					$employeeId = $res->employee_id;
                                                                                //Adding new params to show in lco portal. These values can be editable through in lco portal
                                                                                //on 29-07-2016 Sowmya
                    if($authToken == ""){
                        $authToken = md5(time());
                        $this->WsModel->updatepasstoken_api($authToken,$employeeId);
                    }
                    $base64Image = "";
                    $user_image_name = isset($res->user_image) ? $res->user_image : "";
                    $user_image_path = "";

                    if (!empty($user_image_name)) {
                        $user_image_path = $this->config->item('uploads_path') . "user_images/" . $user_image_name; // $config['uploads_path'] = 'documents/';
                    } else {
                        $user_image_name = "static_user_image.jpg";
                        $user_image_path = $this->config->item('uploads_path') . "user_images/" . $user_image_name;
                    }

                    // Error handling: check if file exists before attempting to get its contents
                    if (!empty($user_image_path) && file_exists($user_image_path)) {
                        try {
                            $imageData = file_get_contents($user_image_path);
                            $base64Image = base64_encode($imageData);
                        } catch (Exception $e) {
                            //log_message('error', 'Failed to get image contents: ' . $e->getMessage());
                            $error = 'Failed to get image contents: ' . $e->getMessage();
                            write_to_file(" ============== userimage path =========== ".$error);
                        }
                    } else {
                        $error = 'File does not exist: ' . $user_image_path;
                        //log_message('error', 'File does not exist: ' . $user_image_path);
                        write_to_file(" ============== userimage path =========== ".$user_image_path);
                    }

                    write_to_file(" ============== userimage path =========== ".$user_image_path);
					$first_name=$res->first_name;
					$last_name=$res->last_name;
					$address1=$res->address1;
					$address2=$res->address2;
					$address3=$res->address3;
					$pin_code=$res->pin_code;
					$copy_rights = $res->copy_rights;
					$short_name = $res->short_name;
					$phone=$res->phone_no;
					$email=$res->email;
					$country=$res->country;
					$state=$res->state;
					$district=$res->district;
					$city=$res->city;
					$username=$res->username;
					$dob=$res->date_of_birth;
					$adate=$res->anniversary_date;
                                                                                $business_name = $res->empbusiness_name;
					$is_unpaidlco = $res->is_unpaidlco;						
					$employeeName = $res->empname;
					$dealerId = $res->dealer_id;			
					$userType = $res->users_type;
					$employeeParentId = $res->employee_parent_id;
					$employeeParentType = $res->employee_parent_type;
					$deposit_amount = $res->deposit_amount;
					$lcoCode = $res->dist_subdist_lcocode;
					$lcoLocation = $res->location_name;
					$lcoMobileNo = $res->mobile_no;
                                                                                $int_is_direct_lco = isset($res->is_direct_lco)?$res->is_direct_lco:0;
                                                                                $accept_terms_condtions=isset($res->accept_terms_condtions)?$res->accept_terms_condtions:1;
                                                                                $access_distributor_wise=isset($res->access_distributor_wise)?$res->access_distributor_wise:0;
                                        
                                                                                if($authToken!=''){
                                                                                    // Prepare jwt token which is necessary in furthur calls
                                                                                    $this->load->library('Jwt_lib');		 
                                                                                    $token_data = array();
                                                                                    $token_data['authtoken'] = $authToken;
                                                                                    // $token_data['noExpiry'] = 1; // Dont check expiry time
                                                                                    $jwtToken = $this->jwt_lib->generateTokenData($token_data,$expiry_in_hours=2160); // 2160 is hours -- 90 days
                                                                                }
					
                                                                                //code to block the payments in written by chakri
					if(isset($userType) && $userType == "DISTRIBUTOR" || $userType == "SUBDISTRIBUTOR" || ($userType == "EMPLOYEE" && ($employeeParentType != "" || $employeeParentType != NULL))){
						$blockpayment = 1;
					}
                    /**** code added by satyam for early login date time insert in early_login_info table ****/
					if($userType == "SERVICE" && $employeeId > 0){
						$is_today_login_done = $this->Service_Employee_Login_Model->is_today_login_done($employeeId);
						if(!$is_today_login_done){
							// Insert login details
							$login_data_array = array(
								"employee_id"		=> 	$employeeId,
								"user_name"			=>	$username,
								"login_date_time"	=>	date('Y-m-d H:i:s'),
								"imei"				=>	$imei,
								"mobile_number"		=>	$res->mobile_no,
								"login_from"		=>	"LCO Mobile APP",
								"remarks"			=>	"Login success",
							);
							$insert_success = $this->Service_Employee_Login_Model->insert_login_date_time($login_data_array);
						}
					}
					$useCRF = $this->WsModel->getLovValue('SHOW_CAF',$dealerId);
					$useCAF = $this->WsModel->getLovValue('CAFNO_CREATION',$dealerId);
					$useLastName = $this->WsModel->getLovValue('IS_LAST_NAME_SHOW',$dealerId);
					$useDiscount = $this->WsModel->getLovValue('SHOW_DISCOUNT',$dealerId);
					$useDataFromMasterTable = $this->WsModel->getLovValue('DATA_FROM_MASTER_TABLE',$dealerId);
					$useMandatoryForHotel = $this->WsModel->getLovValue('MANDATORY_SELECTION_FOR_HOTEL',$dealerId);
					$useLcoDeposit = $this->WsModel->getLovValue('USE_LCO_DEPOSITS',$dealerId);
					$defaultCountry = $this->WsModel->getLovValue('DEFAULT_COUNTRY',$dealerId);
                    $edit_quantity = $this->WsModel->getLovValue('EDIT_QUANTITY',$dealerId);
                    $config_data_object = $this->CountryValidationModel->getCountryValidationByCode($defaultCountry);
                    $enable_box_wise_payment = $this->WsModel->getLovValue('BOX_WISE_PAYMENT',$dealerId);
                    $show_baid = $this->WsModel->getLovValue('SHOW_BAID',$dealerId);
                    if($show_baid == 1){
                        $this->load->model('Reseller_information_model');
                        $baid_label = $this->Reseller_information_model->getCasTerminology($dealerId,"for_baid");
                    }
                    if(!empty($config_data_object)){
                        if(!empty($config_data_object->getMobileLength())){
                            
                            $mobile_length_array = explode(',', $config_data_object->getMobileLength());
                            if(!empty($mobile_length_array)){
                                $config_values_array['min_mobile_length'] = isset($mobile_length_array[0]) ? $mobile_length_array[0] : 10;
                                $config_values_array['max_mobile_length'] = isset($mobile_length_array[1]) ? $mobile_length_array[1] : 10;
                            }
                            
                        }
                        $config_values_array['pincode_length'] = !empty($config_data_object->getPincodeLength()) ? $config_data_object->getPincodeLength() :6;
                        $config_values_array['country_code'] = !empty($config_data_object->getMobileCountryCode()) ? $config_data_object->getMobileCountryCode() : 91;
                    }
                    
                    
                    $country_name = $this->EmployeeModel->getCountryName($defaultCountry);
					$defaultState = $this->WsModel->getLovValue('DEFAULT_STATE',$dealerId);
					$defaultDistrict = $this->WsModel->getLovValue('DEFAULT_DISTRICT',$dealerId);
					$defaultCity = $this->WsModel->getLovValue('DEFAULT_CITY',$dealerId);
					$recurringServiceEdit = $this->WsModel->getLovValue('RECURRING_SERVICE_EDIT',$dealerId);
					$appMenuFormat = $this->WsModel->getLovValue('APP_MENU_FORMAT',$dealerId);
                                                                                $showLcoComplaint = $this->WsModel->getLovValue('SHOW_LCO_COMPLAINT_MANAGEMENT',$dealerId);
                                                                                $invoicepaymentsearchlimit = $this->WsModel->getLovValue('INVOICE_PAYMENT_SEARCH_LIMIT',$dealerId);	
					$freezecustomerparamsinapp = $this->WsModel->getLovValue('FREEZE_CUSTOMER_PARAMS_IN_APP',$dealerId);
					$lco_billtype = $this->WsModel->getLovValue('LCO_BILLTYPE',$dealerId);	
					$use_lco_deposits = $this->WsModel->getLovValue('USE_LCO_DEPOSITS',$dealerId);
					$customer_billtype = $this->WsModel->getLovValue('SHOW_CUSTOMER_BILL_TYPE',$dealerId);
					$AUTO_RECEIPT_NUMBER=$this->WsModel->getLovValue('AUTO_RECEIPT_NUMBER',$dealerId);
					$useAccountNumber = $this->WsModel->get_auto_gen_no($dealerId);
					// Added by Raja kumar on [29-05-2025] for currency symbol from eb_country_validations
                    $this->load->model('CountryValidationModel');
                    $countryCode = $this->LovModel->getDefaultCountry($dealerId);
                    $countryValidation = $this->CountryValidationModel->getCountryValidationByCode($countryCode);
                    if (!empty($countryValidation)) {
      
                         $currencyhtml=$countryValidation->getCurrencyHtmlcode();
                         $currency=$countryValidation->getCurrencyText();

                     } 
                     else{
                        $currency = 'Rs';
                        $currency = '&#8377';
                     }
                    $show_serial_vc=$this->WsModel->getLovValue('DEFAULT_APP_DISPLAY_OF_STB',$dealerId);
                    $show_service_extension=$this->WsModel->getLovValue('SHOW_SERVICE_EXTENSION',$dealerId);
                    if($currency == "Taka"){
                        $currency = "৳";
                    }
                                                                                $int_show_caf_mobile_validation = $this->WsModel->getLovValue('SHOW_MOBILE_VALIDATION', $dealerId);
                                                                                $show_mia_agreement_upload=$this->WsModel->getLovValue('SHOW_MIA_AGREEMENT_UPLOAD',$dealerId);
                                                                                
                                                                                
                                                                                //code for cas access start
                                                                                $access = new AccessModel();
                                                                                $casAccess = array();
                                                                                $access_for['casAccess'] = NULL;
                                                                                //check whether the employee has personal authentication
                                                                                $casAccessResult = $access->getUserCasAccess($employeeId,$dealerId);//employeeid,dealerid

                                                                                //if that employee doesnt have personal authentication check for dealer authentication
                                                                                if(count($casAccessResult)==0)
                                                                                {
                                                                                        $casAccessResult = $access->getCasAccess('RESELLER',$dealerId);
                                                                                }
                                                                                foreach($casAccessResult as $caccess)
                                                                                {
                                                                                        $casAccess[$caccess->stb_module] = $caccess->access;
                                                                                }
                                                                                if(count($casAccess)>0)
                                                                                {
                                                                                        $access_for['casAccess'] = (object)$casAccess;
                                                                                }
                                                                                if(isset($access_for['casAccess']->PAYMENT_GATEWAY_ACCESS) && ($access_for['casAccess']->PAYMENT_GATEWAY_ACCESS==1)) {
                                                                                    $int_allow_top_up=1;
                                                                                }
                                                                                if(isset($access_for['casAccess']->STB_PAIRING) && ($access_for['casAccess']->STB_PAIRING==1)) {
                                                                                    $stb_pairing=1;
                                                                                }
                                                                                if(isset($access_for['casAccess']->STB_UNPAIRING) && ($access_for['casAccess']->STB_UNPAIRING==1)) {
                                                                                    $stb_unpairing=1;
                                                                                }
                                       
										
                                                                                //get the patch information
                                                                                $patch_information = $this->WsModel->get_latest_patch_info();
				}
			}	
			else
			{
				$statusCode = 1;
				$statusMessage = 'Login failed due to invalid Username or Password or User Suspension or User Deactivation or Login User has been blocked.
				Invalid Username or Password.';
			}										
		}
		else
		{
			$statusCode = 1;
			$statusMessage = 'Invalid Username or Password';

		}
	
$response = array(  
        'status_code'=>$statusCode,
        'status_msg'=>$statusMessage,
        //'authToken'=>$authToken,
        'token'=>$jwtToken,
        'employeeId'=>$employeeId,
        'first_name'=>$first_name,
        'last_name'=>$last_name,
        'address1'=>$address1,
        'address2'=>$address2,
        'address3'=>$address3,
        'copy_rights'=>$copy_rights,
        'short_name'=>$short_name,
        'pin_code'=>$pin_code,
        'phone'=>$phone,
        'email'=>$email,
        'country'=>$country,
        'state'=>$state,
        'district'=> $district,
        'city'=>$city,
        'username'=>$username,
        'dob'=>$dob,
        'adate'=>$adate,
        'employeeName'=>$employeeName,
        'dealerId'=>$dealerId,
        'userType'=>$userType,
        'useCRF'=>$useCRF,
        'useCAF'=>$useCAF,
        'useLastName'=>$useLastName,
        'useDiscount'=>$useDiscount,
        'useDataFromMasterTable'=>$useDataFromMasterTable,
        'useMandatoryForHotel'=>$useMandatoryForHotel,
        'useAccountNumber'=>$useAccountNumber,
        'employeeParentId'=>$employeeParentId,
        'employeeParentType'=>$employeeParentType,
        'useLcoDeposit'=>$useLcoDeposit,
        'deposit_amount'=>$deposit_amount,
        'defaultCountry'=>$defaultCountry,
        'country_name'=>$country_name,
        'defaultState'=>$defaultState,
        'defaultDistrict'=>$defaultDistrict,
        'defaultCity'=>$defaultCity,
        'recurringServiceEdit'=>$recurringServiceEdit,
        'showLcoComplaint'=>$showLcoComplaint,
        'lcoCode'=>$lcoCode,
        'lcoLocation'=>$lcoLocation,
        'lcoMobileNo'=>$lcoMobileNo,
        'freezecustomerparamsinapp'=>$freezecustomerparamsinapp,
        'blockpayment'=> $blockpayment,
        'business_name'=> $business_name,
        'is_unpaidlco'=> $is_unpaidlco,
        'appMenuFormat'=>$appMenuFormat,
        'invoicepaymentsearchlimit'=>$invoicepaymentsearchlimit,
        'lco_billtype'=>$lco_billtype,
        'use_lco_deposits'=>$use_lco_deposits,
         'userNotifications'=>$userNotifications,
        'notifyCount'=>0,
        'note_duration'=>$duration,
        'customer_billtype'=>$customer_billtype,
        'AUTO_RECEIPT_NUMBER'=>$AUTO_RECEIPT_NUMBER,
        'CURRENCY_CODE'=>$currency,
        'allow_top_up'=>$int_allow_top_up,
        'show_caf_mobile_validation'=>$int_show_caf_mobile_validation,
        'patch_information' => $patch_information,
        'stb_pairing'=>$stb_pairing,
        'stb_unpairing'=>$stb_unpairing,
        'show_mia_agreement_upload'=>$show_mia_agreement_upload,
        'accept_terms_condtions'=>$accept_terms_condtions,
        'agreement_details_count'=>$agreement_details_count,
        'access_distributor_wise'=>$access_distributor_wise,
        'is_direct_lco'=>$int_is_direct_lco,
        'show_serial_vc' => $show_serial_vc,
        'user_image'=>$base64Image,
        'show_service_extension'=>$show_service_extension,
        'config_values_array'=>$config_values_array,
        'edit_quantity'=>$edit_quantity,
        'enable_box_wise_payment'=>$enable_box_wise_payment,
        'baid_label'=>$baid_label
        );
//        $encry_response = $this->encryption_lib->app_data_encryption($response);
//        $this->response($encry_response, 200);
            $this->sendResponse($response);
        
    }   catch(Exception $e)
                {
                    
                    $this->error_res($e, 200);
                }
        }
/**
 * get dashboard details soap to rest conversion
 * @author Rajesh 06-Dec-2021
 * @params {"use_lco_deposits":"1", "lco_billtype":"0"}
 * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'totalStbs'=>$totalStbs,'totalAssignedStbs'=>$totalAssignedStbs,'totalUnAssignedStbs'=>$totalUnAssignedStbs,'totalComplaints'=>$totalComplaints,'totalClosedComplaints'=>$totalClosedComplaints,'totalActiveCustomers'=>$totalActiveCustomers,'totalDeactiveCustomers'=>$totalDeactiveCustomers,'totalCurrentMonthBill'=>$totalCurrentMonthBill,'totalDueAmount'=>$totalDueAmount,'totalPaidCustomers'=>$totalPaidCustomers,'totalUnPaidCustomers'=>$totalUnPaidCustomers,'gettotalPaidCustomers'=>$gettotalPaidCustomers,'gettotalUnPaidCustomers'=>$gettotalUnPaidCustomers,'outStandingAmount'=>$outStandingAmount,'msoShare'=>$msoShare, 'totalActiveAssignedStbs'=>$totalActiveAssignedStbs, 'totalDeactiveAssignedStbs'=>$totalDeactiveAssignedStbs,'totalCurrentMonthMsoShare'=>$current_month_msoShare,'currentMonthOutstanding'=>$current_month_outstanding,'currentMonthLCOBill'=>$current_month_lco_bill,'lcocurrentmonthdueamount'=>$lco_currentmonth_dueamount)
 */
    
public function dashBoardDetailsRest_post()     {
    try {
          $statusCode = 1;
        $statusMessage='';
    $this->load->model(array('dashboard','dashboardmodel'));
    
   // $this->load->model('WsModel');
            
            $dashboardobj = new dashboard();
           $totalStbs = 0;
            $totalAssignedStbs = 0;
            $totalUnAssignedStbs = 0;
            $totalComplaints = 0;
            $totalClosedComplaints = 0;
            $totalActiveCustomers = 0;
            $totalDeactiveCustomers = 0;
            $totalCurrentMonthBill = 0;
            $totalDueAmount = 0;
            $totalPaidCustomers = 0;
            $current_month_lco_bill=0;
            $lco_currentmonth_dueamount=0;
            $current_month_outstanding=0;
            $totalUnPaidCustomers = 0;
            $current_month_msoShare=0;
            $gettotalPaidCustomers = -1;
            $gettotalUnPaidCustomers = -1;
            $outStandingAmount = -1;
            $msoShare = 0;
            $totalActiveAssignedStbs = 0;
            $totalDeactiveAssignedStbs = 0;
          
           
             //validations start
        
        $validation_fields= array();
        
        $use_lco_deposits = isset($this->payload->use_lco_deposits) ? $this->payload->use_lco_deposits : 0;
        $lco_billtype = isset($this->payload->lco_billtype) ? $this->payload->lco_billtype : 0;
        $validation_fields= ['use_lco_deposits'=>['isInteger','Use LCO Deposits'],'lco_billtype'=>['isInteger','LCO Billtype']];
        $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);

        if(count( $validation_response_array) > 0){
            // validation error
            $statusCode = isset( $validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset( $validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

           
          //Validation end      
            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();

            if($employeeId != 0 && $dealerId != 0)
            {
                $access = $this->WsModel->accessControl($employeeId,$dealerId);	
                
              
        $user_data = $this->WsModel->getUserDetails($employeeId,$dealerId);
        $logged_employee = $employeeId;
        $user_type =$user_data->users_type;
        $logged_user_type = $user_type;
        $parent_idforaccess = $employeeId;
        if(($user_data->users_type=='EMPLOYEE') && ($user_data->employee_parent_type=='DISTRIBUTOR' || $user_data->employee_parent_type=='SUBDISTRIBUTOR' ||  $user_data->employee_parent_type=='RESELLER')){
        $user_type = $user_data->employee_parent_type;
        $logged_user_type = $user_data->employee_parent_type;
        $employeeId = isset($user_data->parent_id)?$user_data->parent_id:$employeeId;
        $parent_idforaccess = isset($user_data->parent_id)?$user_data->parent_id:$employeeId;
        }
        if(($user_data->users_type=='EMPLOYEE') && ( $user_data->employee_parent_type=='RESELLER')){
            $logged_employee =isset($user_data->parent_id)?$user_data->parent_id:$employeeId;
        }
        if(($user_data->users_type=='EMPLOYEE') && ($user_data->employee_parent_type=='')){
        $user_type = 'dealer';
        $logged_user_type = 'EMPLOYEE';
        $employeeId = 1;
        $parent_idforaccess = 1;
        }
        if(($user_data->users_type=='ADMIN') && ($user_data->employee_parent_type=='')){
            $user_type = 'dealer';
            $logged_user_type = 'ADMIN';
            $employeeId = 1;
            $parent_idforaccess = 1;
        }
        $dashboard_data=$dashboardobj->getDataByUserType($user_type,$dealerId);
        if((!empty($access) > 0 && isset($access->DASHBOARD->view) && $access->DASHBOARD->view == 1) || ($user_data->users_type == 'DISTRIBUTOR' || $user_data->users_type == 'SUBDISTRIBUTOR'))
        {
                $obj_dash = new dashboardmodel();
                $statusCode = 0;
                $statusMessage = 'Success';
                $this->load->model('Change_pass_model');             
        $lov_val = $this->Change_pass_model->getLovValue($lov_setting='LCO_EMPLOYEE_GROUP_CUSTOMER',$dealerId); //new line added by rajesh
        $extra_params = array('lov_emp_grp_customers'=>$lov_val);  //new line added by rajesh
        // foreach($dashboard_data as $row) {
        //         if($row->names=='total_stbs' && $row->status==1) {
        //             $totalStbs = $obj_dash->totalStbs('', $dealerId, $employeeId, $phase=0,  $new_dashboard=0,$is_setup_box=1, $extra_params);  //added extra parameters from totalstbs function
        //         }

        //         if($row->names=='assigned_stbs' && $row->status==1) {
        //             $totalAssignedStbs = $obj_dash->totalAssignedStbs($dealerId, $employeeId, $active=0,$extra_params);
        //         }

        //         if($row->names=='unassigned_stbs' && $row->status==1) {
        //             $totalUnAssignedStbs = $obj_dash->totalNotAssignedStbs($dealerId, $employeeId, $int_flag=0);  //no sessions
        //         }

        //         if($row->names=='total_complaints' && $row->status==1) {
        //             $totalComplaints = $obj_dash->totalComplaints($dealerId, $employeeId, $extra_params);  
        //         }
        //         if($row->names=='closed_complaints' && $row->status==1) {
        //             $totalClosedComplaints = $obj_dash->totalClosedComplaints($dealerId, $employeeId, $extra_params);  
        //         }
        //         // $totalActiveCustomers = $obj_dash->totalActiveCustomers($dealerId,$employeeId);
        //         // $totalDeactiveCustomers = $obj_dash->totalDeactiveCustomers($dealerId,$employeeId);
        //         if($row->names=='active_stbs' && $row->status==1) {
        //             $totalActiveCustomers = $obj_dash->totalActiveSTBs($dealerId, $employeeId,$new_dashboard=0,$is_setup_box=1, $extra_params);
        //         }
        //         if($row->names=='deactive_stbs' && $row->status==1) {
        //             $totalDeactiveCustomers = $obj_dash->totalDeactiveSTBs($dealerId, $employeeId,$new_dashboard=0,$is_setup_box=1, $extra_params);
        //         }
        //         if($row->names=='current_month_billing' && $row->status==1) {
        //             $totalCurrentMonthBill = $obj_dash->totalCurrentMonthBill($dealerId, $employeeId,$plugin_id=4, $extra_params);
        //         }
        //         if($row->names=='paid_customers' && $row->status==1) {
        //             $totalPaidCustomers = $obj_dash->paidCustomers($dealerId, $employeeId,$str_user_type='',$lco_groups=0);  //no sessions
        //             $gettotalPaidCustomers = $obj_dash->getPaidCustomers($dealerId, $employeeId,$plugin_id=4, $extra_params);
        //         }
        //         if($row->names=='unpaid_customers' && $row->status==1) {
        //             $totalUnPaidCustomers = $obj_dash->unpaidCustomers($dealerId, $employeeId,$str_user_type='',$lco_groups=0); //no sessions
        //             $gettotalUnPaidCustomers = $obj_dash->getUnpaidCustomers($dealerId, $employeeId,$plugin_id=4, $extra_params);
        //         }
        //     }
            $this->load->library('dashboard/charts/DashboardData');
            $DashboardData = new DashboardData();
            $getDashboardItemsLibrary = $DashboardData->getDashboardItems($dealerId, $employeeId,$user_type,$logged_employee);
            
            $getDashboardItemsLibrary_access = $DashboardData->getDashboardItems($dealerId, $parent_idforaccess,$logged_user_type,$logged_employee);
            $totalAssignedStbs        = 0;
            $totalUnAssignedStbs      = 0;
            $totalStbs                = 0;
            $totalActiveAssignedStbs  = 0;
            $totalDeactiveAssignedStbs= 0;
            $totalComplaints          = 0;
            if (!empty($getDashboardItemsLibrary)) {
                foreach ($getDashboardItemsLibrary as $dashboardItem) {

                    if (empty($dashboardItem->items)) {
                        continue;
                    }

                    $items = json_decode($dashboardItem->items, true);
                    if (empty($items)) {
                        continue;
                    }

                    foreach ($items as $item) {

                        $itemName = $item['item_name'] ?? '';
                        $viewData = $item['view_data'] ?? [];

                        // ---- STB INFO SECTION ----
                        if ($dashboardItem->section_name == 'stb_info') {

                            switch ($itemName) {
                                case 'assigned_stbs':
                                    $totalAssignedStbs = $viewData['assigned_stbs'] ?? 0;
                                    break;

                                case 'unassigned_stbs':
                                    $totalUnAssignedStbs = $viewData['unassigned_stbs'] ?? 0;
                                    break;

                                case 'total_stbs':
                                    $totalStbs = $viewData['total_stbs'] ?? 0;
                                    break;

                                case 'active_stbs':
                                    $totalActiveAssignedStbs = $viewData['active_stbs'] ?? 0;
                                    break;

                                case 'inactive_stbs':
                                    $totalDeactiveAssignedStbs = $viewData['deactive_stbs'] ?? 0;
                                    break;
                            }
                        }

                        // ---- CHART INFO SECTION ----
                        if ($dashboardItem->section_name == 'chart_info' && $itemName == 'complaints_chart') {
                            $totalComplaints = $viewData['total'] ?? 0;
                        }
                    }
                }
            }
            


            // Extract assigned_stbs from JSON data
            $totalAssignedStbs_access        = 0;
            $totalUnAssignedStbs_access      = 0;
            $totalStbs_access                = 0;
            $totalActiveAssignedStbs_access  = 0;
            $totalDeactiveAssignedStbs_access= 0;
            $totalComplaints_access          = 0;
            if (!empty($getDashboardItemsLibrary_access)) {
                foreach ($getDashboardItemsLibrary_access as $dashboardItem) {

                    if (empty($dashboardItem->items)) {
                        continue;
                    }

                    $items = json_decode($dashboardItem->items, true);
                    if (empty($items)) {
                        continue;
                    }

                    foreach ($items as $item) {

                        $itemName = $item['item_name'] ?? '';
                        $viewData = $item['view_data'] ?? [];

                        // ---- STB INFO SECTION ----
                        if ($dashboardItem->section_name == 'stb_info') {

                            switch ($itemName) {
                                case 'assigned_stbs':
                                    $totalAssignedStbs_access = $viewData['assigned_stbs'] ?? 0;
                                    break;

                                case 'unassigned_stbs':
                                    $totalUnAssignedStbs_access = $viewData['unassigned_stbs'] ?? 0;
                                    break;

                                case 'total_stbs':
                                    $totalStbs_access = $viewData['total_stbs'] ?? 0;
                                    break;

                                case 'active_stbs':
                                    $totalActiveAssignedStbs_access = $viewData['active_stbs'] ?? 0;
                                    break;

                                case 'inactive_stbs':
                                    $totalDeactiveAssignedStbs_access = $viewData['deactive_stbs'] ?? 0;
                                    break;
                            }
                        }

                        // ---- CHART INFO SECTION ----
                        if ($dashboardItem->section_name == 'chart_info' && $itemName == 'complaints_chart') {
                            $totalComplaints_access = $viewData['total'] ?? 0;
                        }
                    }
                }
            }
            write_to_file(" ========== totalAssignedStbs_access query ========= ".$totalAssignedStbs_access);
            write_to_file(" ========== totalUnAssignedStbs_access query ========= ".$totalUnAssignedStbs_access);
            write_to_file(" ========== totalStbs_access query ========= ".$totalStbs_access);
            write_to_file(" ========== totalActiveAssignedStbs_access query ========= ".$totalActiveAssignedStbs_access);
            write_to_file(" ========== totalDeactiveAssignedStbs_access query ========= ".$totalDeactiveAssignedStbs_access);
            write_to_file(" ========== totalComplaints_access query ========= ".$totalComplaints_access);
            
            if($totalAssignedStbs_access  == 0){
                $totalAssignedStbs = 0;
            }if($totalUnAssignedStbs_access == 0){
                $totalUnAssignedStbs = 0;
            }if($totalStbs_access == 0){
                $totalStbs = 0;
            }if($totalActiveAssignedStbs_access == 0){
                $totalActiveAssignedStbs = 0;
            }if($totalDeactiveAssignedStbs_access == 0){
                $totalDeactiveAssignedStbs = 0;
            }
            if($totalComplaints_access == 0){
                $totalComplaints = 0;
            }
            $outStandingAmount = $obj_dash->getOutstandingAmount($employeeId);      //no sessions                          
            $msoShare = $obj_dash->msoShare($employeeId);    //no sessions 
            // $totalActiveAssignedStbs = $obj_dash->totalAssignedStbs($dealerId, $employeeId, $active=1, $extra_params);
            // $totalDeactiveAssignedStbs = $obj_dash->totalAssignedStbs($dealerId, $employeeId, $active=2, $extra_params);
            write_to_file(" ========== totalDeactiveAssignedStbs query ========= ".$this->db->last_query());
            $current_month_msoShare = $obj_dash->current_month_msoShare($dealerId, $employeeId);                            //no sessions
            $current_month_outstanding = $obj_dash->current_month_outstanding($dealerId, $employeeId);      //no sessions
            $current_month_lco_bill = $obj_dash->lco_current_month_billing($dealerId, $employeeId);          //no sessions
            
            $lco_currentmonth_dueamount = $obj_dash->lco_currentmonth_dueamount($dealerId,$employeeId,$lco_billtype,$use_lco_deposits); //no sessions


            }
            else
            {
                    $statusCode = 1;
                    $statusMessage = 'You do not have sufficient privileges.';			
            }
            }
            else
            {
                    $statusCode = 1;
                    $statusMessage = 'Employee or dealer does not exist';
            }
          	
            $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'totalStbs'=>$totalStbs,'totalAssignedStbs'=>$totalAssignedStbs,'totalUnAssignedStbs'=>$totalUnAssignedStbs,'totalComplaints'=>$totalComplaints,'totalClosedComplaints'=>$totalClosedComplaints,'totalActiveCustomers'=>$totalActiveAssignedStbs,'totalDeactiveCustomers'=>$totalDeactiveAssignedStbs,'totalCurrentMonthBill'=>$totalCurrentMonthBill,'totalDueAmount'=>$totalDueAmount,'totalPaidCustomers'=>$totalPaidCustomers,'totalUnPaidCustomers'=>$totalUnPaidCustomers,'gettotalPaidCustomers'=>$gettotalPaidCustomers,'gettotalUnPaidCustomers'=>$gettotalUnPaidCustomers,'outStandingAmount'=>$outStandingAmount,'msoShare'=>$msoShare, 'totalActiveAssignedStbs'=>$totalActiveAssignedStbs, 'totalDeactiveAssignedStbs'=>$totalDeactiveAssignedStbs,'totalCurrentMonthMsoShare'=>$current_month_msoShare,'currentMonthOutstanding'=>$current_month_outstanding,'currentMonthLCOBill'=>$current_month_lco_bill,'lcocurrentmonthdueamount'=>$lco_currentmonth_dueamount);
//            $encry_response = $this->encryption_lib->app_data_encryption($response);
//            $this->response($encry_response, 200);
            $this->sendResponse($response);
    }
         catch(Exception $e)
                {
                    
                    $this->error_res($e);
                }
        }
    /**
     * get lco deposit amount soap to rest conversion
     * @author Rajesh 08-Dec-2021
     * @params void
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'deposit_amount' => $lco_deposit_amount)
     */
    
public function lco_deposit_amountRest_post()  // auth-token 60ec53c37fc6d2.56511413
    {
        try
        {
                $obj = new WsModel();
                $employeeId = $this->getEmployeeId();//$obj->isValidPassToken($authToken); // new line added 
                $dealerId = $this->getDealerId();//$obj->getDealerId($employeeId); // new line added
                $lco_deposit_amount='';

                if ($employeeId > 0 && $dealerId > 0) {
                        $lco_deposit_amount = $this->WsModel->lco_deposit_amount($employeeId, $dealerId);
                        // log_message('debug',$this->db->last_query());

                        if ($lco_deposit_amount != '') {
                            $statusCode = 0;
                            $statusMessage = 'Success';
                        } else {
                            $statusCode = 1;
                            $statusMessage = 'No 1 records found';
                        }
                } else {
                        $statusCode = 1;
                        $statusMessage = 'No 2 records found';
                }
               
                //return (array('statusCode' => $statusCode, 'statusMessage' => $statusMessage, 'lco_deposit_amount' => $lco_deposit_amount));
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'deposit_amount' => $lco_deposit_amount);
                $this->sendResponse($response);
        }
        catch(Exception $e)
        {

                $this->error_res($e, 200);
        }
    }
        
        
 /**
     * get customer details count soap to rest conversion
     * @author Soujanya 7-7-2023
     * @params {"mobileNumber":"919601795347"} // lcoCustomerId // boxNumber // mobileNumber // customerNumber // customerName
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerCount'=>$customerCount)
    */
public function getCustomerDetailsCountRest_post()   //auth-token 5fb9ea11df0697.51848119
{
    try{
        $statusCode=1;
        //validation start
        $validation_fields=array();
        $validation_error=false;
        $customerNumber = isset($this->payload->customerNumber) ? trim($this->payload->customerNumber) : '';
        $use_lco_deposits = isset($this->payload->use_lco_deposits) ? trim($this->payload->use_lco_deposits) :0;
        $customerName = isset($this->payload->customerName) ? trim($this->payload->customerName) : '';
        $mobileNumber  = isset($this->payload->mobileNumber) ? trim($this->payload->mobileNumber) :'';
        $boxNumber  = isset($this->payload->boxNumber) ? trim($this->payload->boxNumber) :'';
        $lcoCustomerId  = isset($this->payload->lcoCustomerId) ? trim($this->payload->lcoCustomerId) :'';
        $validation_fields=['customerNumber'=>['isString','Customer Number'],'use_lco_deposits'=>['isInteger','Use LCO Deposits'],'customerName'=>['isString','customerName'],'mobileNumber'=>['isString','Mobile Number'],'boxNumber'=>['isString','Box Number'],'lcoCustomerId'=>['isString','lco Customer Id']];
        $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);

        if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

          //Validation end
        $obj = new WsModel();
        $employeeId = $this->getEmployeeId(); 
	$dealerId = $this->getDealerId();
        $customerCount = 0;
        $customerDetailsList = array();
        
        if($employeeId != 0 && $dealerId != 0)
        {
                if(!empty($mobileNumber)){
                    $this->load->model(array('CountryValidationModel'));
                    $defaultCountry = $this->WsModel->getLovValue('DEFAULT_COUNTRY',$dealerId);
                    $config_data_object = $this->CountryValidationModel->getCountryValidationByCode($defaultCountry);
                    if(!empty($config_data_object)){
                        if(!empty($config_data_object->getMobileLength())){
                            
                            $mobile_length_array = explode(',', $config_data_object->getMobileLength());
                            if(!empty($mobile_length_array)){
                                $config_values_array['min_mobile_length'] = isset($mobile_length_array[0]) ? $mobile_length_array[0] : 10;
                                $config_values_array['max_mobile_length'] = isset($mobile_length_array[1]) ? $mobile_length_array[1] : 10;
                            }
                            
                        }
                        $config_values_array['pincode_length'] = !empty($config_data_object->getPincodeLength()) ? $config_data_object->getPincodeLength() :6;
                        $config_values_array['country_code'] = !empty($config_data_object->getMobileCountryCode()) ? $config_data_object->getMobileCountryCode() : 91;
                        $mobileNumber = $config_values_array['country_code'].$mobileNumber;
                    }
                }
                $customerCount = $this->WsModel->getCustomerDetailsCount($customerNumber,$customerName,$mobileNumber,$boxNumber,$lcoCustomerId,$dealerId,$employeeId);
                write_to_file(" ============ getCustomerDetailsCount ============= ".$this->db->last_query());
                if($customerCount > 0)
                {
                        $statusCode = 0;
                        $statusMessage = 'Success';

                }
                else
                {
                        $statusMessage = 'Customer does not exist';				
                }
        }
        else
        {
                $statusMessage = 'Dealer or Employee does not exist';				
        }
       
            $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerCount'=>$customerCount);
            $this->sendResponse($response);
            
                }
                catch(Exception $e)
                {
                    
                    $this->error_res($e, 200);
                }
                
}




/**
 * get existing customer soap to rest conversion
 * @author soujanya 7-7-2023
 * @params mobileNumber // customerNumber // lcoCustomerId // boxNumber // mobileNumber // cafNumber KDN000002 // customerName // endValue
 * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'existCustomerDetails'=>$existCustomerDetails)
*/
public function getCustomerDetailsRest_post()
{ try {
    
     $statusCode = 1;
        $statusMessage='';
        $total_amount='';
        $mso_share='';
        $tot_mso_share ='';  	
        $lco_share='';
        $baid_label="";
        //validations
        $validation_fields=array();
        $validation_error=false;
   
        
        $customerNumber = isset($this->payload->customerNumber) ? trim($this->payload->customerNumber) : '';
        $customerName = isset($this->payload->customerName) ? trim($this->payload->customerName) : '';
        $mobileNumber = isset($this->payload->mobileNumber) ? trim($this->payload->mobileNumber) : '';
        $boxNumber = isset($this->payload->boxNumber) ? trim($this->payload->boxNumber) : '';
        $lcoCustomerId = isset($this->payload->lcoCustomerId) ? trim($this->payload->lcoCustomerId) : '';
        $cafNumber = isset($this->payload->cafNumber) ? trim($this->payload->cafNumber) : '';
        $startValue = isset($this->payload->startValue) ? trim($this->payload->startValue) : 0;
        $endValue = isset($this->payload->endValue) ? trim($this->payload->endValue) : 0;
        
        $validation_fields=['customerNumber'=>['isString','Customer Number'],'customerNumber'=>['isString','Customer Number'],'customerName'=>['isString','Customer Name'],'mobileNumber'=>['isString','Mobile Number'],'boxNumber'=>['isString','Box Number'],'lcoCustomerId'=>['isString','lco Customer Id'],'cafNumber'=>['isString','CAF Number'],'startValue'=>['isInteger','Start Value'],'endValue'=>['isInteger','End Value']];
         
//        log_message('debug','start'.$startValue);
//        log_message('debug','end'.$endValue);
     $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
         if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
          //Validation end
    
        $obj = new WsModel();
        $this->load->model('BulkOperationModel');
        $obj_bulk_operations = new bulkoperationmodel();
        $this->load->model('Change_pass_model');
        $cpm = new Change_pass_model();
        $employeeId = $this->getEmployeeId(); 
	$dealerId = $this->getDealerId();
        $customerCount = 0;
        $customerDetailsList = array();
        $stbCount = 0;

       
        if($employeeId>0 && $dealerId>0)
        {
               // log_message("debug","==========customerDetailsList============".json_encode($customerNumber));  
                if(!empty($mobileNumber)){
                    $this->load->model(array('CountryValidationModel'));
                    $defaultCountry = $this->WsModel->getLovValue('DEFAULT_COUNTRY',$dealerId);
                    $config_data_object = $this->CountryValidationModel->getCountryValidationByCode($defaultCountry);
                    if(!empty($config_data_object)){
                        if(!empty($config_data_object->getMobileLength())){
                            
                            $mobile_length_array = explode(',', $config_data_object->getMobileLength());
                            if(!empty($mobile_length_array)){
                                $config_values_array['min_mobile_length'] = isset($mobile_length_array[0]) ? $mobile_length_array[0] : 10;
                                $config_values_array['max_mobile_length'] = isset($mobile_length_array[1]) ? $mobile_length_array[1] : 10;
                            }
                            
                        }
                        $config_values_array['pincode_length'] = !empty($config_data_object->getPincodeLength()) ? $config_data_object->getPincodeLength() :6;
                        $config_values_array['country_code'] = !empty($config_data_object->getMobileCountryCode()) ? $config_data_object->getMobileCountryCode() : 91;
                        $mobileNumber = $config_values_array['country_code'].$mobileNumber;
                    }
                }
                $res = $obj->getCustomerDetails($customerNumber,$customerName,$mobileNumber,$boxNumber,$startValue,$endValue,$lcoCustomerId,$dealerId,$employeeId,$cafNumber);
                write_to_file(" ============ getCustomerDetails query ============= ".$this->db->last_query());  
                if(isset($res) && count($res)>0 )
                {
                        
                        $int_allow_mso_adj = $cpm->getLovValue('BILL_EDIT_CUSTOMER_ADJUSTMENT', $dealerId);
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        $show_baid = $this->WsModel->getLovValue('SHOW_BAID',$dealerId);
                        if($show_baid == 1){
                            $this->load->model('Reseller_information_model');
                            $baid_label = $this->Reseller_information_model->getCasTerminology($dealerId,"for_baid");
                        }
                        foreach($res as $k=>$v){
                                $customerDetailsList[$k]=$v;
                                // added by venkat start
                                    $int_reseller_id = isset($v->pending_amount) ? $res[0]->reseller_id : 0;
                                    $arr_employee_details = $obj_bulk_operations->getEmployeeDetails($int_reseller_id);
                                    $int_is_direct_lco = isset($arr_employee_details->is_direct_lco) ? $arr_employee_details->is_direct_lco : 0;
                                    $v->is_direct_lco = $int_is_direct_lco;
                                    $customerDetailsList[$k] = $v;
                                // added by venkat end 
                        }
                        $latest =$obj->latest_invoice($res[0]->customer_id,$dealerId,$int_allow_mso_adj);
                        $total_amount = 0;
                        $mso_share = 0;
                        $lco_share = 0;
                        if(!empty($latest)){
                            $total_amount = $latest[0]->total_amount;
                            $mso_share = $latest[0]->mso_share;
                            $lco_share = $latest[0]->lco_share;
                        }
                        //$lco_share = $total_amount - $mso_share;
                        $totmso_share = $obj->total_mso_share($res[0]->customer_id,$dealerId,$int_allow_mso_adj);
                        $tot_mso_share = $totmso_share[0]->tot_mso_share;

                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = 'Customer does not exist';
                        $customerDetailsList[0] = (object)array('customerId'=>'','customerName'=>'','cafNumber'=>'','mobileNumber'=>'','status'=>'','billingAddress'=>'','installationAddress'=>'','pinCode'=>'','crfNumber'=>'','stbCount'=>$stbCount,'box_number'=>'','vc_number'=>'','account_number'=>'','pending_amount'=>'0','total_amount'=>'0','mso_share'=>'0','tot_mso_share'=>'0','lco_share'=>'0','latitude'=>'0.0','longitude'=>'0.0','bill_type'=>'',"baid_label"=>$baid_label);					
                }
        }
        else
        {
                $statusCode = 1;
                $statusMessage = 'Dealer or Employee does not exist';
                $customerDetailsList[0] = (object)array('customerId'=>'','customerName'=>'','cafNumber'=>'','mobileNumber'=>'','status'=>'','billingAddress'=>'','installationAddress'=>'','pinCode'=>'','crfNumber'=>'','stbCount'=>$stbCount,'box_number'=>'','vc_number'=>'','account_number'=>'','pending_amount'=>'0','total_amount'=>'0','mso_share'=>'0','tot_mso_share'=>'0','lco_share'=>'0','latitude'=>'0.0','longitude'=>'0.0','bill_type'=>'',"baid_label"=>$baid_label);				
        }
       
        $response = array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage,'customerDetailsList'=>$customerDetailsList,'total_amount'=>$total_amount,'mso_share'=>$mso_share,'tot_mso_share'=>$tot_mso_share,'lco_share'=>$lco_share,"baid_label"=>$baid_label);	 
        $this->sendResponse($response);
 }
                catch(Exception $e)
                {
                    
                    $this->error_res($e, 200);
                }
                }

               

    /**
     * get existing customer soap to rest conversion
     * @author soujanya 7-7-2023
     * @params {"accountNumber":"C0007828"}// stbNumber // cafNumber // tempActivation
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'existCustomerDetails'=>$existCustomerDetails)
    */
public function existingCustomerRest_post(){   // auth-token 5fb9ea11df0697.51848119
    try
    {
        //validations
        $validation_fields=array();
        $statusCode = 1;
        $user_type="";
        $parent_user_type="";
        $accountNumber = isset($this->payload->accountNumber) ? $this->payload->accountNumber : '';
        $stbNumber = isset($this->payload->stbNumber) ? $this->payload->stbNumber : '';
        $cafNumber = isset($this->payload->cafNumber) ? $this->payload->cafNumber : '';
        $tempActivation = isset($this->payload->tempActivation) ? $this->payload->tempActivation : '';
        $validation_fields=['accountNumber'=>['isString','Account Number'],'stbNumber'=>['isString','STB Number'],'cafNumber'=>['isString','CAF Number'],'tempActivation'=>['isString','temp Activation']];

        $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
         if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

         
          //Validation end
                $obj = new WsModel();
                $employeeId = $this->getEmployeeId(); 
                $dealerId = $this->getDealerId();

                $existCustomerDetails = array();
                $statusMessage = 'Customer Details Not found';
                $show_caf_val = $this->WsModel->checkUseCRFNumber($dealerId);
                
                if($employeeId > 0 && $dealerId > 0)
                {
                        $this->load->model('CustomersModelNew');
                        if($accountNumber!= '' || $stbNumber!='' || $cafNumber !=''){
                                $existCustomerDetails = $this->CustomersModelNew->getOldCustomerDetails($dealerId, $employeeId, $accountNumber, $lco_customer_id='', $stbNumber, $is_surr=0, $tempActivation,$cafNumber,$show_caf_val=0,$user_type,$parent_user_type, $customer_number='', $lco_customer_id='', $vc_number='');
                                write_to_file(" ============= getOldCustomerDetails query ======= ".$this->db->last_query());
                   // $this->write_to_file($this->db->last_query());	
                                if(!empty($existCustomerDetails)){
                                        $statusCode = 0;
                                        $statusMessage = 'Customer details found successfully';
                                }
                        }
                }else
                {
                        $statusCode = 1;
                        $statusMessage = 'Dealer or Employee does not exist.';	
                        $existCustomerDetails[0] = (object)array('customer_id' => '','password' => '','business_name' => '','first_name' => '','last_name' => '','address1' => '','address2' => '','address3' =>'' ,'city' => '','district' => '','state' =>'','country' => '','pin_code' => '','phone_no' =>'' ,'mobile_no' => '','email' => '','date_of_birth' => '','anniversary_date' => '','status' => '','dealer_id' => '','created_by' => '','created_date' => '','last_updated_by' => '','last_updated_date' => '','account_number' => '','remarks' => '','is_reseller' => '','reseller_id' => '','reseller_project_id' => '','caf_no' => '','subscribe_to_news_letter' => '','user_name' => '','username_changed' => '','id_type' => '','id_number' => '','fathers_name' =>'' ,'signup_date' => '','signup_changed' => '','baid' => '','base_station_id' => '','customersla_id' => '','installation_address' => '','digi_id' =>'','customer_account_id' => '','customer_seq_number' => '','customer_update' => '','customer_type_id' => '','customer_type_types_id' => '','gender' => '','customer_type_description' => '','is_lco_transferred' => '','new_customer_id' => '','discount' => '','caf_status' => '','assigned_stbs' => '','stb_count' => '','bill_type' => '','longitude' => '','latitude' => '','pan_number' => '','tin_number' => '','service_tax_number' => '','registration_number' =>'' ,'tan_number' => '','user_id' =>'' ,'is_verified' =>'','verified_by' => '','verified_date' => '','total_bill_amount' => '','total_paid_amount' => '','balance' => '','customer_type' => '','is_commercial_multi_box' => '','value' =>'' ,'hotel_hospital' => '','location_name' => '','sales_date' => '','printable_name' => '','district_name' => '','group_name' => '','emp_name' => '' ,'location_id' => '','group_id' => '' ,'' => '');
                }
                
                //return (array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage, 'existCustomerDetails'=>$existCustomerDetails));
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'existCustomerDetails'=>$existCustomerDetails);
                $this->sendResponse($response);
                }
                catch(Exception $e)
                {
                    
                    $this->error_res($e, 200);
                }
        }

    /**
     * get pending amount soap to rest conversion
     * @author soujanya 7-7-2023
     * @params {"altCustomerId": "78"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerName'=>$customerName,'mobileNumber'=>$mobileNumber,'pendingAmount'=>$amount,'billingId'=>$billingId,'msoShare'=>$mso_share,'lcoShare'=>$lco_share)
     */
public function getPendingAmountRest_post() {
   try {
                $statusCode = 1;
		$statusMessage = '';
           //validations start
                $validation_error=false;
                $validation_fields=['altCustomerId'=>['isInteger|isRequired','alt Customer Id']];
                $validation_response_array=  $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);

                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
          //Validation end
                
                
		$obj = new WsModel();
                $this->load->model('Change_pass_model');
		$Change_pass_model = new Change_pass_model();	
		$employeeId = $this->getEmployeeId(); 
                $dealerId = $this->getDealerId();	
              
		if($employeeId != 0 && $dealerId != 0)
		{	
                 $altCustomerId=trim($this->payload->altCustomerId); 
                 $lov_box_wise_payment = $this->WsModel->getLovValue('BOX_WISE_PAYMENT',$dealerId);
                 $lov_box_wise_payment = 1;
                 //$this->payload->serial_no = "22621140135945"; // This is for test purpose
                 if($lov_box_wise_payment == 1){
                    $this->load->model(array('PaymentsModel','Kal_api_model'));
                    $this->load->library('Kal_api_lib');
                    $serial_no=isset($this->payload->serial_no)?$this->payload->serial_no:"";
                    // Get Stock id of Serial number
                    $stock_id = $this->Kal_api_model->getStockid($serial_no);
                    $customer_due_object = $this->PaymentsModel->getCustomerDueAmountDetails($altCustomerId, $billing_cutoff_date = '', $payment_cutoff_date = '',$dealerId,$stock_id,$lov_box_wise_payment);
                    if(!empty($customer_due_object)){
                        $float_current_pending_mso_share = isset($customer_due_object->mso_share_due)?$customer_due_object->mso_share_due:0;
                        $estimated_mso_share_array = $this->kal_api_lib->get_mso_share($dealerId,$employeeId,$altCustomerId,$stock_id);
                        $estimated_mso_share = isset($estimated_mso_share_array['MSO_AMOUNT'])?$estimated_mso_share_array['MSO_AMOUNT']:0;
                        if($estimated_mso_share > 0){
                            $float_current_pending_mso_share += $estimated_mso_share;
                        }
                        $float_current_pending_mso_share = sprintf("%.2f", round($float_current_pending_mso_share, 2));
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        $customerName = isset($customer_due_object->name)?$customer_due_object->name:"";
                        $amount = isset($customer_due_object->amount)?$customer_due_object->amount:"0.00";
                        $billingId = "";
                        $mobileNumber = isset($customer_due_object->mobile_no)?$customer_due_object->mobile_no:"";
                        $mso_share=$float_current_pending_mso_share;
                        $lco_share="0.00";
                    }
                    else
                    {
                        $statusMessage = 'No records found.';
                    }
                        
                 } 
                 else{
                    $result = $this->WsModel->getLatestBillDetails($altCustomerId,$dealerId);
                    if(!empty($result))
                    {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        $customerName = $result->name;
                        $amount = $result->amount;
                        $billingId = $result->billing_id;
                        $mobileNumber = $result->mobile_no;
                                            $mso_share=$result->mso_share;
                        $lco_share=$result->lco_share;
                    }
                    else
                    {
                        $statusMessage = 'No records found.';
                    }
                 }
		}
		else
		{
			$statusMessage = 'No records found.';
		}
               
		$response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerName'=>$customerName,'mobileNumber'=>$mobileNumber,'pendingAmount'=>$amount,'billingId'=>$billingId,'msoShare'=>$mso_share,'lcoShare'=>$lco_share);
                $this->sendResponse($response);
                
                }
                        catch(Exception $e)
                {
                    
                    $this->error_res($e, 200);
                }
        }
	
        
    /**
     * get Payment Modes soap to rest conversion
     * @author Rajesh 10-Dec-2021
     * @params void
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'paymentModesList'=>$paymentModesList)
     */
public function getPaymentModesRest_post()
{   try {
        $obj = new WsModel();
        //$employeeId = 0;
        //$dealerId = 0;
        $statusCode=1;
        $statusMessage='No Record Found';
        $employeeId = $this->getEmployeeId(); 
        $dealerId = $this->getDealerId();
       
        if($employeeId > 0 && $dealerId > 0)
        {
                $res = $this->WsModel->getPaymentModes();
                $paymentModesList = array();
                //if(count($res) > 0)
                if(!empty($res))
                {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        foreach($res as $k=>$v){
                                $paymentModesList[$k]=$v;
                        }
                }
        }
        else
        {
                $statusCode = 1;
                $statusMessage = 'Dealer or Employee does not exist';
                $paymentModesList[0] = (object)array('paymentModeId'=>'','paymentModeName'=>'');
        }
       
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'paymentModesList'=>$paymentModesList);
        $this->sendResponse($response);
        }
                        catch(Exception $e)
                {
                    
                    $this->error_res($e, 200);
                }
}

    /**
     * make payments soap to rest conversion
     * @author soujanya 7-7-2023
     * @params any param
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,
     */
public function makePaymentsRest_post()
    { try {
        $validation_fields=array();
        $receipt_number = isset($this->payload->receipt_number) ? $this->payload->receipt_number : '';
        $customerId = isset($this->payload->altCustomerId) ? $this->payload->altCustomerId : '';
        $amount = isset($this->payload->amount) ? $this->payload->amount : 0;
        //$authToken = isset($this->payload->authToken) ? $this->payload->authToken : '';
        $chequeNo = isset($this->payload->chequeNo)?($this->payload->chequeNo):'';
        $bank = isset($this->payload->bank)?($this->payload->bank):'';
        $branch = isset($this->payload->branch)?($this->payload->branch):'';
        $chequeDate = isset($this->payload->chequeDate)?($this->payload->chequeDate):0;
        $altReceiptNumber = isset($this->payload->altReceiptNumber)?($this->payload->altReceiptNumber):'';
        $remarks = isset($this->payload->remarks)?($this->payload->remarks):'';
        $billingId = isset($this->payload->billingId)?($this->payload->billingId):'';
        $rrnNo = isset($this->payload->rrnNo)?($this->payload->rrnNo):'';
        $cardholderName = isset($this->payload->cardholderName)?($this->payload->cardholderName):'';
        $modeType = isset($this->payload->modeType)?($this->payload->modeType):'';
        $voucherCode = isset($this->payload->voucherCode)?($this->payload->voucherCode):'';
        
        $validation_fields=['receipt_number'=>['isString','receipt number'],'altCustomerId'=>['isString','altCustomerId'],'amount'=>['isString','amount'],'authToken'=>['isString','authToken'],'chequeNo'=>['isString','chequeNo'],'bank'=>['isString','bank'],'branch'=>['isString','branch'],'chequeDate'=>['checkValidDate','chequeDate'],'altReceiptNumber'=>['isString','altReceiptNumber'],'remarks'=>['isString','remarks'],'billingId'=>['isString','billingId'],'rrnNo'=>['isString','rrnNo'],'cardholderName'=>['isString','cardholderName'],'modeType'=>['isString','modeType'],'voucherCode'=>['isString','voucherCode']];
        $validation_response_array=  $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
        
        write_to_file("Inside makePayments start");
        $obj = new WsModel();
        $obj1 = new Change_pass_model();
        $cf_objj = new CommonFunctions();
        $format ='';
        $success_count = 0;
        $failure_count = 0;
        $return_array = array();
        $error = '';
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                $authToken = $this->getAuthToken();
       $auto_receipt_num=$obj->getLovValue('AUTO_RECEIPT_NUMBER',$dealerId);
        if($auto_receipt_num == 0){
            //$receipt_number=trim($customerInfo->receipt_number);
        }
        else{
            $receipt_number='';
        }
 
        //log_message('debug','customerInfo - '.json_encode($customerInfo));
        //write_to_file("Inside makePayments customerInfo".json_encode($customerInfo));
        $invalid_access = 0;
             
        //digi_key added for validating correct server from where BILL is getting accessed by Swaroop
        //$digi_key = (isset($customerInfo->digi_config_value) && (strlen(trim($customerInfo->digi_config_value)) > 0))?trim($customerInfo->digi_config_value):'';
                $digi_key = (isset($this->payload->digi_config_value) && (strlen(trim($this->payload->digi_config_value)) > 0))?trim($this->payload->digi_config_value):'';
        log_message('debug','Digi Key==== - '.$digi_key);
        //if digi_key is there we will take bill_dealer_id from paramenters and we will get employee_id from that dealer_id
        if($digi_key!=''){
            $digi_key_in_bill = ($this->config->item('digi_key'))?$this->config->item('digi_key'):'';
            log_message('debug','digi_key_in_bill - '.$digi_key_in_bill);
            if($digi_key==$digi_key_in_bill){
                //Get the dealer_id and employee_id from auth token
                $dealerId = (isset($this->payload->bill_dealer_id) && ($this->payload->bill_dealer_id) > 0)?$this->payload->bill_dealer_id:0;
                $employeeId = $obj->getEmployeeIdForDealer($dealerId);
                                //$employeeId = $this->getEmployeeId(); 
            }
            else{
                //return as invalid access
                $statusCode = 1;
                $statusMessage = 'Invalid Access.';
                //return (array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage,'customerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>$success_count,'failureCount'=>$failure_count,'error_msg'=>$error));
            } 
        }
        
        
        log_message('debug','employeeId - '.$employeeId);
        log_message('debug','dealerId - '.$dealerId);
        //die;

        $imei = (isset($this->payload->imei) && (strlen(trim($this->payload->imei)) > 0))?trim($this->payload->imei):'';
        write_to_file("In makePayments employeeId".$employeeId."dealerId".$dealerId);
        if($employeeId>0 && $dealerId>0)
        {
            write_to_file("In makePayments  in if employeeId".$employeeId."dealerId".$dealerId);
            $payment_records = isset($this->payload->customerid_Amt)?json_decode($this->payload->customerid_Amt):array();
            if(count($payment_records)==0){
                //$customerId = isset($customerInfo->altCustomerId)?trim($customerInfo->altCustomerId):0;
                //$amount = isset($customerInfo->amount)?trim($customerInfo->amount):0;
                $payment_records[] = array('customer_id'=>$customerId,'amount'=>$amount,'digi_activation_from'=>0);
            }
            write_to_file("In makePayments  in if payment_records".json_encode($payment_records));
            if(!empty($payment_records)){
                $voucherDetails=array();
                $allVoucherList=array();

                if($modeType=='voucher'){
                    $voucherDetails=(object)array("voucherCode"=>$voucherCode,"authToken"=>$authToken);
                      //log_message('debug','$voucherDetails '.$voucherDetails);        
                    $result = $this->voucherVerification($voucherDetails);
                    if($result['statusCode'] == 1){
                        $statusCode=$result['statusCode'];
                        $statusMessage=$result['statusMessage'];
                        $error .= 'Customer : '.$customerId.' - statusMessage : '.$statusMessage;
                    //$return_array =  (array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage,'customerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>$success_count,'failureCount'=>$failure_count,'error_msg'=>$error));  
                    $return_array = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'c1ustomerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>$success_count,'failureCount'=>$failure_count,'error_msg'=>$error);
                                        $this->sendResponse($return_array);
                                        
                                        }

                    if($result['statusCode']==0){

                        $allVoucherList=$result['allVoucherList'];          
                        $statusCode=0;
                        $statusMessage=$result['statusMessage'];
                        $amount=$allVoucherList->voucher_value;
                        $voucherCode=isset($allVoucherList->voucher_code)?$allVoucherList->voucher_code:'';
                        $smsurl = $cf_objj->checkUrl()."payments/WS_makePayment";
                                              

                    }
                }

                //end here voucher code
                $requestId = 40;

                $useLcoDep = $obj->useLcoDeposits($dealerId);   
                /*if($useLcoDep && $modeType!='voucher'){               
                    $smsurl = $cf_objj->checkUrl()."Customer/WS_makeBulkPayment";
                }else{              
                    $smsurl = $cf_objj->checkUrl()."payments/WS_makePayment";
                }*/ 

                //smsurl made to default because both functionalities are same and we have deposit checkings in both wrappers by Swaroop Mar 1 2018
                $smsurl = $cf_objj->checkUrl()."payments/WS_makePayment";
                log_message('debug','smsurl - '.$smsurl);
                write_to_file("In makePayments  in if payment_records smsurl".$smsurl);
                $data = array(
                    //'altCustomerId' => urlencode($customerId),
                    'authToken' => urlencode($authToken),
                    //'amount' => urlencode($amount),
                    'chequeNo' => urlencode($chequeNo),
                    'bank' => urlencode($bank),
                    'branch' => urlencode($branch),
                    'chequeDate' => urlencode($chequeDate),
                    'billingId' => urlencode($billingId),
                    'altReceiptNumber' => urlencode($altReceiptNumber),
                    'remarks' => urlencode($remarks),
                    'employeeId' => urlencode($employeeId),
                    'dealerId' => urlencode($dealerId),
                    'requestId' => urlencode($requestId),
                    'requestServerIp' => urlencode($this->serverIp),
                    'imei' => urlencode($imei),
                    'rrnNo' => urlencode($rrnNo),
                    'cardholderName' => urlencode($cardholderName),
                    'modeType' => urlencode($modeType),
                    'use_lco_deposit' => $useLcoDep,
                    'voucherCode'=>$voucherCode,
                    'payment_records'=>json_encode($payment_records),
                    'digi_key'=>urlencode($digi_key),
                    'receipt_number'=>urlencode($receipt_number) // Added by Ajeet 09-10-2019
                    );
                
                //$response = trim($obj->callCurl($smsurl,$data));
                // $return_array = json_decode($response);
                // Added by Prasad on 23-oct-20
                $array_dealer_setting = array();
                $this->load->library('LovModel');
                $dealrSettings = $this->LovModel->setDealerSettings($dealerId);
                if (!empty($dealrSettings)) {
                    $array_dealer_setting = (array) $dealrSettings;
                }
                $arr_customer_details['customer_id'] = $customerId;
                $arr_customer_details['reseller_id'] = $employeeId; 
                $extra_params['arr_customer_details'] = $arr_customer_details;
                $extra_params['payment_reseller_id'] = $employeeId;
                //$extra_params['payment_type'] = 2;$payment_type;
                $extra_params['bulk_remarks']=$extra_params['remarks'] = $remarks;
                $extra_params['payment_mode'] =$modeType;
                $extra_params['customer_payment_with_amount'] = 1;
                $extra_params['dealer_id'] = $dealerId;
                $extra_params['login_employee_id'] = $employeeId;
                $extra_params['dealer_setting'] = $array_dealer_setting;
                $operation_name = 'customer_payment_from_app';
                $this->load->model(array('Workflow_model','Process_Model','Provisioning_model'));
                $int_operation_id= $this->Process_Model->getoperation_id($operation_name,$dealerId);
                $extra_params['int_operation_id']=$int_operation_id;
                $arr_plugin = $this->Workflow_model->getPluginDetails($dealerId);
                $extra_params['plugins'] = $arr_plugin;
                $extra_params['str_act_remarks'] = $operation_name;
                $str_reason_name = "Activation From Bulk Payment";
                $int_act_reason_id = $this->Provisioning_model->getReasons($str_reason_name);
                $extra_params['int_act_reason'] = $int_act_reason_id;
                $this->load->library('Customermakepayment');

                $lov_box_wise_payment = $this->WsModel->getLovValue('BOX_WISE_PAYMENT',$dealerId);
                $int_stock_id = 0;
                if($lov_box_wise_payment == 1){
                    $this->load->model(array('Kal_api_model'));
                    $serial_no=isset($this->payload->serial_no)?$this->payload->serial_no:"";
                    // Get Stock id of Serial number
                    //$serial_no = "22621140135945";
                    $int_stock_id = $this->Kal_api_model->getStockid($serial_no);
                }
                if(1 == $lov_box_wise_payment && $int_stock_id > 0){
                    $arr_stock_id = array($int_stock_id);
                }else{
                    $arr_stock_id = array();
                }
                $this->load->model(array('PaymentsModel'));
                $customer_due_object = $this->PaymentsModel->getCustomerDueAmountDetails($customerId, $billing_cutoff_date = '', $payment_cutoff_date = '',$dealerId,$int_stock_id,$lov_box_wise_payment);
                $due_amount = isset($customer_due_object->amount)?$customer_due_object->amount:0;
                if($due_amount == 0){
                    $due_amount = $amount;
                }
                $extra_params['customer_amount'] = $extra_params['payment_amount'] = $due_amount;
                //print_r($extra_params);
                $response = $this->customermakepayment->paymentProcess(array($customerId),$paid_at_mso=0,$dealerId,$receipt_nums="",$enable_bulk_payment_bgprocess=0,$extra_params,$fromCustomerPortal=0,$arr_stock_id);
                //-{"status":1,"failed_cusotmer_id":[],"failed_customers":[],"int_payment_id":2167927}
                //print_r($result);
              //  $this->write_to_file("----------- makepayment response -------".json_encode($response));

                                //log_message('debug', 'Response : '.$response);
                // Tue, 08 Aug 23 14:58:42 +0530::Data - In makePayments  in if payment_records response{"status":1,"failed_cusotmer_id":[],"failed_customers":[],"int_payment_id":2195145}
                if(isset($response['status']) && $response['status'] ==1 && isset($response['int_payment_id']) && $response['int_payment_id']>0)
                {
                    //$return_array = json_decode($response);
                    // log_message('debug', 'return_array - '.print_r($return_array, true));
                    //$statusCode = 0;
                    //$statusMessage = "Success";
                    //$return_array = (array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'c2ustomerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>1,'failureCount'=>0,'error_msg'=>""));
                    $statusCode = 0;
                    $statusMessage = "Payment successful.";

                    /*
                        customerName
                        mobile
                        email
                        city
                        state
                        pin
                        receiptNumber
                        amount
                        billAmount
                        customNumber
                        lco_business_name
                        lco_city
                        lco_state
                        lco_pincode
                        last_paid_amt
                        last_paid_date
                        mode
                        collection_employee
                        format
                        lco_balance
                        voucherCode

                    */
                    $payment_data = $obj->get_payment_details($response['int_payment_id']);
                    //print_r($payment_data);
                   // write_to_file("----------------- payment_data -----------".json_encode($payment_data));
                    //$return_array = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerName'=>'dsadsa','mobile'=>'9640374122','email'=>'dsdsads@gmail.com','city'=>'Hyderabad','state'=>'Telangana','pin'=>'507164','billNumber'=>'415454','receiptNumber'=>'4546545','altReceiptNumber'=>'545456','amount'=>'100.00','billAmount'=>'100.00','customNumber'=>'456464','lco_business_name'=>'test','lco_city'=>'hyderabad','lco_state'=>'Telangana','lco_pincode'=>'507164','last_paid_amt'=>'100.00','last_paid_date'=>'2023-08-14','mode'=>'Cash','collection_employee'=>'','format'=>'','lco_balance'=>'4500.00','voucherCode'=>'','successCount'=>1,'failureCount'=>0,'error_msg'=>"");
                    if(!empty($payment_data)){
                        $return_array = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerName'=>$payment_data->customerName,'mobile'=>$payment_data->mobile,'email'=>$payment_data->email,'city'=>$payment_data->city,'state'=>$payment_data->state,'pin'=>$payment_data->pin,'billNumber'=>"",'receiptNumber'=>$payment_data->receiptNumber,'altReceiptNumber'=>"",'amount'=>$amount,'billAmount'=>$payment_data->amount,'customNumber'=>$payment_data->customNumber,'lco_business_name'=>$payment_data->lco_business_name,'lco_city'=>$payment_data->lco_city,'lco_state'=>$payment_data->lco_state,'lco_pincode'=>$payment_data->lco_pincode,'last_paid_amt'=>'100.00','last_paid_date'=>'','mode'=>$payment_data->mode,'collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>1,'failureCount'=>0,'error_msg'=>"");
                    }
                    else{
                        $statusCode = 1;
                        $statusMessage = 'Payment failed, Something went wrong or due to path mismatch.';
                                $return_array = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'c2ustomerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>$success_count,'failureCount'=>$failure_count,'error_msg'=>$error);
                                $this->sendResponse($return_array);
                    }
                    

                }else{
                    $statusCode = 1;
                    $statusMessage = isset($response['failed_customers'][0]['message'])?$response['failed_customers'][0]['message']:"Payment failed, Inernal Server error";
                                $return_array = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'c2ustomerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>$success_count,'failureCount'=>$failure_count,'error_msg'=>$error);
                                $this->sendResponse($return_array);         
                }
                // End, Added by Prasad on 23-oct-20
                // log_message('debug','final makepaymentresponse - '.print_r($return_array,true));
                //log_message('debug','makepaymentresponse - '.print_r($return_array,true));    
                write_to_file("In makePayments  in if payment_records response".json_encode($response));        
            }
        }
        else
        {
            write_to_file("In makePayments in else");
            $statusCode = 1;
            $statusMessage = 'Dealer or Employee does not exist.';
            $return_array = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'c3ustomerName'=>'','mobile'=>'','email'=>'','city'=>'','state'=>'','pin'=>'','billNumber'=>'','receiptNumber'=>'','altReceiptNumber'=>'','amount'=>'','billAmount'=>'','customNumber'=>'','lco_business_name'=>'','lco_city'=>'','lco_state'=>'','lco_pincode'=>'','last_paid_amt'=>'','last_paid_date'=>'','mode'=>'','collection_employee'=>'','format'=>'','lco_balance'=>'','voucherCode'=>'','successCount'=>$success_count,'failureCount'=>$failure_count,'error_msg'=>$error);
                        $this->sendResponse($return_array);
        }
              
        
        $this->sendResponse ($return_array);
    }
                 catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
}


    /**
     * get Customer Box Details soap to rest conversion
     * @author soujanya 7-7-2023
     * @params  {"customerId":"78"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerBoxList'=>$customerBoxList)
     */
public function getCustomerBoxDetailsRest_post()    
        { try {
                 $statusCode = 1;
		$statusMessage = '';
            $customerBoxList = array();
           //validations start
                $validation_fields=['customerId'=>['isInteger|isRequired','Customer ID']];
                $validation_response_array=  $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                if(count($validation_response_array) > 0){  
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }


          //Validation end
                $obj = new WsModel();
                $employeeId = $this->getEmployeeId(); 
                $dealerId = $this->getDealerId();
                $customerId=trim($this->payload->customerId); 
                $userType =$this->post('userType')?(trim($this->post('userType'))):'';
               
                if($employeeId != 0 && $dealerId != 0)
                {
                        $res = $obj->getCustomerBoxDetails($customerId,$employeeId,$dealerId,$userType);
                        $customerBoxList = array();
                        //if(count($res) > 0)
                        if(!empty($res))
                        
                        {
                                $statusCode = 0;
                                $statusMessage = 'Success';
                                foreach($res as $k=>$v){
                                        $customerBoxList[$k]=$v;
                                }
                        }
                        else
                        {
                                //$statusCode = 1;
                                $statusMessage = 'Customer does not have the STB';
                                //$customerBoxList[0] = (object)array('customerId'=>'','customerName'=>'','serialNumber'=>'','vcNumber'=>'','boxNumber'=>'','macAddress'=>'','stockStatus'=>'','stockId'=>'','deviceId'=>'','backEndSetupId'=>'');					
                        }
                }
                else
                {
                        //$statusCode = 1;
                        $statusMessage = 'Dealer or Employee does not exist';			
                        //$customerBoxList[0] = (object)array('customerId'=>'','customerName'=>'','serialNumber'=>'','vcNumber'=>'','boxNumber'=>'','macAddress'=>'','stockStatus'=>'','stockId'=>'','deviceId'=>'','backEndSetupId'=>'');				
                }
               
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerBoxList'=>$customerBoxList);
                $this->sendResponse($response);
                 }
                        catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
                }
        
        
    /**
     * get Customer Particular Box Details soap to rest conversion
     * @author soujanya 7-7-2023
     * @params {"customerId":7191, "stockId":4}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage, 'is_temp_deactivated'=>$is_temp_deactivated,'customerParticularBoxList'=>$customerParticularBoxList,'is_expired_service'=>$is_expired_service)
     */        
public function getCustomerParticularBoxDetailsRest_post()
        { try {

                 $statusCode = 1;
		$statusMessage = '';
            $temp_reason = 8;
            $is_temp_deactivated=0;
            $expiry_reason = 3;
            $is_expired_service=0;
            $is_unpaid_service = 0;
            $customerParticularBoxList = array();
           //validations start
                $validation_fields=['customerId'=>['isInteger','Customer ID'],'stockId'=>['isInteger','Stock ID']];
                $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
               if(count($validation_response_array) > 0){  
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }


          //Validation end
                $this->load->model(array('CustomersModel','DasModel'));
                $obj = new WsModel();
                $cust = new CustomersModel();
                //Get the dealer_id and employee_id from auth token
                $employeeId = $this->getEmployeeId(); 
                $dealerId = $this->getDealerId();
                $customerId=trim($this->payload->customerId); 
                $stockId=trim($this->payload->stockId); 
                $userType=trim($this->payload->userType); 
                $show_replacement = 0;
                $replacement_types_array = array();
                $stb_replacement_form_validations = array();
                $amount_mandatory = 0;
                $receipt_number_mandatory = 0;
                if($employeeId != 0 && $dealerId != 0)
                {
                        //$is_unpaid_service=$cust->checkTemporaryDeactivatedCustomer($customerId,$stockId, $dealerId, trim($unpaid_reason=2));
                        if($is_unpaid_service == 0){
                            $is_temp_deactivated=$cust->checkTemporaryDeactivatedCustomer($customerId,$stockId, $dealerId, trim($temp_reason));
                            if($is_temp_deactivated == 0){
                                    $is_expired_service=$cust->checkTemporaryDeactivatedCustomer($customerId,$stockId, $dealerId, trim($expiry_reason));
                            }
                            $show_replacement = $obj->getLovValue('SHOW_REPLACEMENT_IN_LCO_MOBILE_APP',$dealerId);
                            write_to_file(" ======== getCustomerParticularBoxDetailsRest SHOW_REPLACEMENT_IN_LCO_MOBILE_APP =====".$show_replacement);
                            if($show_replacement == 1){
                                $replacement_types = $this->DasModel->getReplacementTypes($replacement_id=0,$userType,"RESELLER");
                                write_to_file(" ======== getCustomerParticularBoxDetailsRest replacement_types =====".json_encode($replacement_types));
                                if(!empty($replacement_types)){
                                    foreach ($replacement_types as $key => $value) {
                                        $replacement_types_array [] = array("replacement_type_id"=>$value->replacement_type_id,"replacement_type"=>$value->replacement_type); 
                                    }
                                }
                                write_to_file(" ======== getCustomerParticularBoxDetailsRest replacement_types_array =====".json_encode($replacement_types_array));
                                $amount_mandatory = 0;
                                $receipt_number_mandatory = 0;
                                $form_validations = $cust->getCustomerFormValidation('eb_replaced_stb');
                                write_to_file(" ======== getCustomerParticularBoxDetailsRest form_validations =====".json_encode($form_validations));
                                if(!empty($form_validations)){
                                    if(isset($form_validations['amount']) && $form_validations['amount'] == 1){
                                        $amount_mandatory = 1;
                                    }
                                    if(isset($form_validations['receipt_number']) && $form_validations['receipt_number'] == 1){
                                        $receipt_number_mandatory = 1;
                                    }
                                }
                            }
                            $stb_replacement_form_validations = array("amount_mandatory"=>$amount_mandatory,"receipt_number_mandatory"=>$receipt_number_mandatory);
                            write_to_file(" ======== getCustomerParticularBoxDetailsRest stb_replacement_form_validations =====".json_encode($stb_replacement_form_validations));
                            $res = $obj->getCustomerParticularBoxDetails($customerId,$employeeId,$dealerId,$userType,$stockId);
                            $customerParticularBoxList = array();
                            //if(count($res) > 0)
                            if(!empty($res))
                            {
                                    $statusCode = 0;
                                    $statusMessage = 'Success';
                                    foreach($res as $k=>$v){
                                            $customerParticularBoxList[$k]=$v;
                                    }
                                    //write_to_file(" =========== Box details vc_number ====== ".$customerParticularBoxList);
                                    //print_r($customerParticularBoxList);exit;
                                    if(isset($customerParticularBoxList[0]->vc_number) && $customerParticularBoxList[0]->vc_number == ""){
                                        $customerParticularBoxList = array();
                                        $statusCode = 1;
                                        $statusMessage = 'Box is not in paired status';
                                    }
                                    if(isset($customerParticularBoxList[0]->is_temp_blocked) && $customerParticularBoxList[0]->is_temp_blocked == 1){
                                        $customerParticularBoxList = array();
                                        $statusCode = 1;
                                        $statusMessage = 'Box is temporarily blocked';
                                    }
                            }
                            else
                            {
                                    //$statusCode = 1;
                                    $statusMessage = 'Customer does not have a box';
                                    //$customerParticularBoxList[0] = (object)array('customerId'=>'','customerName'=>'','serialNumber'=>'','vcNumber'=>'','boxNumber'=>'','macAddress'=>'','stockStatus'=>'','stockId'=>'','deviceId'=>'','backEndSetupId'=>'','backEndSetupId'=>'');					
                            }
                        }
                        else
                        {
                                //$statusCode = 1;
                                $statusMessage = 'Box cannot be activated due to unpaid deactivation reason';
                                //$customerParticularBoxList[0] = (object)array('customerId'=>'','customerName'=>'','serialNumber'=>'','vcNumber'=>'','boxNumber'=>'','macAddress'=>'','stockStatus'=>'','stockId'=>'','deviceId'=>'','backEndSetupId'=>'','backEndSetupId'=>'');                   
                        }
                }
                else
                {
                       // $statusCode = 1;
                        $statusMessage = 'Dealer or Employee does not exist';			
                        //$customerParticularBoxList[0] = (object)array('customerId'=>'','customerName'=>'','serialNumber'=>'','vcNumber'=>'','boxNumber'=>'','macAddress'=>'','stockStatus'=>'','stockId'=>'','deviceId'=>'','backEndSetupId'=>'','backEndSetupId'=>'');				
                }
               
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage, 'is_temp_deactivated'=>$is_temp_deactivated,'customerParticularBoxList'=>$customerParticularBoxList,'is_expired_service'=>$is_expired_service,"show_replacement"=>$show_replacement,"replacement_types"=>$replacement_types_array,'stb_replacement_form_validations'=>$stb_replacement_form_validations);
                write_to_file(" ======== getCustomerParticularBoxDetailsRest response =====".json_encode($response));
                $this->sendResponse($response);
                
                }	
            catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
        }
                     

    /**
         * get Deactive Reasons soap to rest conversion
         * @author Rajesh 14-Dec-2021
         * @params void
         * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'reasonList'=>$reasonList)
         */  
public function getDeactiveReasonsRest_post()
{ try {
        $obj = new WsModel();
        $employeeId = $this->getEmployeeId();
        $dealerId = $this->getDealerId();
        //$show_for_lco = isset($customerInfo->showforlco)?$customerInfo->showforlco:0;
        //$show_for_lco =$this->post('showforlco')?(trim($this->post('showforlco'))):0;
        $show_for_lco=isset($this->payload->showforlco)?trim($this->payload->showforlco):0; // integer
        $stock_id=isset($this->payload->stockId)?trim($this->payload->stockId):0;
        if($employeeId != 0 && $dealerId != 0)
        {
                $user_data = $this->WsModel->getUserDetails($employeeId,$dealerId);
                $user_type =isset($user_data->users_type)?$user_data->users_type:"";
                if($user_type == "RESELLER" || $user_type == "EMPLOYEE"){
                    $show_for_lco = 1;
                }
                $res = $obj->getDeactivationRemarks($show_for_lco);
                if($stock_id > 0){
                    $customer_id_v2 = $this->WsModel->getCustomerIdV2ByStockId($stock_id);
                    $array_dealer_setting = array();
                    $this->load->library('LovModel');
                    $dealrSettings = $this->LovModel->setDealerSettings($dealerId);
                    if (!empty($dealrSettings)) {
                        $array_dealer_setting = (array) $dealrSettings;
                    }
                    $session_lov_params = array(
                        'USE_LCO_DEPOSITS' => isset($array_dealer_setting['USE_LCO_DEPOSITS'])?$array_dealer_setting['USE_LCO_DEPOSITS']:0,
                        'CHECK_INDIVIDUAL_DEPOSITS' => isset($array_dealer_setting['CHECK_INDIVIDUAL_DEPOSITS'])?$array_dealer_setting['CHECK_INDIVIDUAL_DEPOSITS']:0,
                        'BOX_WISE_PAYMENT' => isset($array_dealer_setting['BOX_WISE_PAYMENT'])?$array_dealer_setting['BOX_WISE_PAYMENT']:0
                    );
                    $lov_box_wise_payment = isset($array_dealer_setting['BOX_WISE_PAYMENT'])?$array_dealer_setting['BOX_WISE_PAYMENT']:0;
                    $customer_due_exist = false; // 0 - has due ,1 - no due
                    if($lov_box_wise_payment == 1){
                        $this->load->model('Customer360Model');
                        $customer_due_status = $this->Customer360Model->customerDueStatus($customer_id_v2, $dealerId, $employeeId, $session_lov_params,$stock_id);
                        if($customer_due_status == 0){
                            $customer_due_exist = true;
                        }
                    }
                    // Choose which reason name to remove
                    $reasonToRemove = $customer_due_exist ? 'Temporary Deactivation' : 'Unpaid Customer';
                    // Filter the array
                    $res = array_filter($res, function($item) use ($reasonToRemove) {
                        return $item->reasonName !== $reasonToRemove;
                    });

                    // Reindex the array
                    $res = array_values($res);
                }
                $reasonList = array();
                //if(count($res)>0)
                if(!empty($res))
                {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        foreach($res as $k=>$v)
                        {
                                $reasonList[$k]=$v;
                        }
                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = 'No records found.';
                        $reasonList[0] = (object)array('reasonId'=>'','reasonName'=>'');
                }
        }
        else
        {
                $statusCode = 1;
                $statusMessage = 'Dealer or Employee does not exist.';
                $reasonList[0] = (object)array('reasonId'=>'','reasonName'=>'');
        }
       
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'reasonList'=>$reasonList);
        $this->sendResponse($response);
}        
            catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
        }

    /**
    * get Customer Packages split soap to rest conversion
    * @author soujanya 7-7-2023
    * @params {"customerId":29,"boxNumber":"23120370003930"}
    * @return array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'packageList_base'=>$packageList_base,'packageList_addon'=>$packageList_addon,'packageList_ala'=>$packageList_ala,'packageList_broadcaster'=>$packageList_broadcaster)
    */  
public function getCustomerPackages_splitRest_post()
{ try {


     $this->load->model("WsModel");
                 $statusCode = 1;
		$statusMessage = '';
                //validations start
                $validation_fields=['customerId'=>['isInteger','Customer ID'],'boxNumber'=>['isString','Box Number']];
                $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                if(count($validation_response_array) > 0){  
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                $this->load->library(array('Service_extension_lib'));
                 //Validation end
                $obj = new WsModel();
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                //$employeeId=52;
                //$employeeId=87;
                //$dealerId= 1;

//                $customerId =$this->post('customerId')?(trim($this->post('customerId'))):'';
//                $boxNumber =$this->post('boxNumber')?(trim($this->post('boxNumber'))):'';
               
                $customerId=trim($this->payload->customerId);
                $boxNumber=trim($this->payload->boxNumber);
               
        $packageList_base = array();
        $packageList_addon = array();
        $packageList_ala = array();
        $packageList_broadcaster = array();
      
        if($employeeId != 0 && $dealerId != 0)
        {
        $res = $obj->getcustomerservices_split($customerId,$boxNumber,$dealerId);

        
        /*$this->load->model(array('NewCustomerWithStbModel','Productsmodel'));
        $arrSerialNumber = array($boxNumber);
        write_to_file(" ========= Assigned Packages boxNumber ======== ".json_encode($arrSerialNumber));
        $arrAssingnServiceDetails = $this->NewCustomerWithStbModel->getcustomerservices($customerId, $dealerId, $ottOrCas=0, $searched_serial_number = '', $searched_vc_number = '', $arrSerialNumber, $service_status = 1,$str_backend_setup_ids = '',$arr_stock_id=array());
        write_to_file(" ========= Assigned Packages arrAssingnServiceDetails ======== ".json_encode($arrAssingnServiceDetails));
        if(!empty($arrAssingnServiceDetails)){
            foreach ($arrAssingnServiceDetails as $row){
                write_to_file(" ========= Assigned Packages arrAssingnServiceDetails row ======== ".json_encode($row));
                $product_price_details_array = $this->Productsmodel->target_wise_product_price_list($row->product_id,$dealerId);
                            //print_r($product_price_details);exit;
                $product_price = isset($product_price_details_array['MSO'][0]['price'])?$product_price_details_array['MSO'][0]['price']:"0.00";
                write_to_file(" ========= Assigned Packages arrAssingnServiceDetails product_price ======== ".json_encode($product_price));
                $alacarte = $row->alacarte;
                $is_base_package = $row->is_base_package;
                $is_broadcaster_package = $row->is_broadcaster_package;
                // {"base_price":"130.00","is_taxable":"0","customer_service_id":"4210334","product_name":"KA-BASIC TIER","product_id":"2281","sd_channels_count":"153","hd_channels_count":"0","alacarte":"0","is_base_package":"1","is_broadcaster_package":"0","validity_days":"1","monthly_or_yearly":"(Per Month)","validity":"Month(s)","tax1":"9.00","tax2":"9.00","tax3":"0.00","tax4":"0.00","tax5":"0.00","tax6":"0.00","customer_name":"DUMMY","service_start_date":"2024-12-30 14:55:48","service_end_date":"2027-12-29 14:55:48","cas_server_type":"CDCAS"}


                //{"service_type":"1","billing_schedule_id":"1","product_id_v2":"2281","stock_id_v2":"155014","customer_device_id_v2":"240524","billing_type_id":"1","reseller_id_v2":"592","vc_number_v2":"000083330005DF27","expected_deactivation_time":"2025-12-29 23:59:59","validity_days_v2":"1","old_customer_service_id":"4202439","service_start_date_timestamp":"1735550748","option2":"","option3":null,"option4":"0","cust_id":"229514","bill_type":"1","reseller_name":"Neha T","reseller_id":"592","balance":"0.00","created_date":"2023-10-01 00:00:00","is_verified":"1","business_name":"Sree Sampangi Cable Network","dist_subdist_lcocode":"VKBNG236","users_type":"RESELLER","is_base_package":"1","alacarte":"0","is_broadcaster_package":"0","sd_channels_count":"153","hd_channels_count":"0","stock_id":"155014","updated_reseller_name":"Neha T","updated_business_name":"Sree Sampangi Cable Network","updated_dist_subdist_lcocode":"VKBNG236","updated_users_type":"RESELLER","serial_number":"000083330005DF27","stb_type_id":"2","stb_blocked_for_lco":"0","display_name":"NSTV","backend_setup_id":"1","is_temp_blocked":"0","not_paired_in_cas":"0","mac_vc_number":"000083330005DF27","product_id":"2281","product_name":"KA-BASIC TIER","bundle":"0","show_baseprice":"0","device_name":null,"order_service_id":"4210334","parent":null,"billing_schedule_display_name":"Recurring-Monthly","is_default":"0","billing_type_display_name":"Advance"}
                $statusCode = 0;
                $statusMessage = 'Success';
                $validity_days = "Test";
                if(isset($row->validity_days_v2) && $row->validity_days_v2 > 1){
                    $validity_days = "";
                    if($row->validity_days_v2 == 1){
                        $validity_days = "Month(s)";
                    }
                    if($row->validity_days_v2 == 2){
                        $validity_days = "Year(s)";
                    }
                    if($row->validity_days_v2 == 3){
                        $validity_days = "Day(s)";
                    }
                }
                if($alacarte == '1'){
                   $packageList_ala[]=(object)array("base_price"=>$product_price,"is_taxable"=>"","customer_service_id"=>$row->customer_service_id,"product_name"=>$row->product_name,"product_id"=>$row->product_id_v2,"validity"=>$validity_days,"sd_channels_count"=>$row->sd_channels_count,"hd_channels_count"=>$row->hd_channels_count);
                }
                else if($is_base_package == '1'){
                   $packageList_base[]=(object)array("base_price"=>$product_price,"is_taxable"=>"","customer_service_id"=>$row->customer_service_id,"product_name"=>$row->product_name,"product_id"=>$row->product_id_v2,"validity"=>$validity_days,"sd_channels_count"=>$row->sd_channels_count,"hd_channels_count"=>$row->hd_channels_count,"alacarte"=>$alacarte,"is_base_package"=>$is_base_package,"is_broadcaster_package"=>$is_broadcaster_package,"service_start_date"=>"","service_end_date"=>"","cas_server_type"=>"");

                }
                else if($is_broadcaster_package == '1'){
                   $packageList_broadcaster[]=(object)array("base_price"=>$product_price,"is_taxable"=>"","customer_service_id"=>$row->customer_service_id,"product_name"=>$row->product_name,"product_id"=>$row->product_id_v2,"validity"=>$validity_days,"sd_channels_count"=>$row->sd_channels_count,"hd_channels_count"=>$row->hd_channels_count);

                }
                else{
                   $packageList_addon[]=(object)array("base_price"=>$product_price,"is_taxable"=>"","customer_service_id"=>$row->customer_service_id,"product_name"=>$row->product_name,"product_id"=>$row->product_id_v2,"validity"=>$validity_days,"sd_channels_count"=>$row->sd_channels_count,"hd_channels_count"=>$row->hd_channels_count);
                }
            }
            //write_to_file(" ========= Assigned Packages arrAssingnServiceDetails Base Package ======== ".json_encode($packageList_base1));
        }*/
        
        // log_message('debug', 'response - '.print_r($res, true));
       
        if(count($res)>0)
        {
            $statusCode = 0;
            $statusMessage = 'Success';
            foreach ($res as $row){

                $int_validity_days = isset($row->service_validity_days_v2)?$row->service_validity_days_v2:0;
                $int_service_type = isset($row->service_type)?$row->service_type:0;
                $date_service_enddate =   isset($row->service_end_date)?$row->service_end_date:'';
                
                $formattedEndDate = date('d-m-Y', strtotime($date_service_enddate));
                $array_extension_date_params = array('int_service_type'=>$int_service_type,
                'int_validity_days'=>$int_validity_days,
                'date_service_enddate'=>$formattedEndDate,
                'int_quantity'=>1,
                'int_product_billing_type'=>''
                );
               
               $array_response = $this->service_extension_lib->calculateServiceExtensionDate($array_extension_date_params);
               $service_end_date = isset($array_response['extension_date'])?$array_response['extension_date']:'';
               $row->extend_service_enddate = $service_end_date;
               $alacarte = $row->alacarte;
               $is_base_package = $row->is_base_package;
               $is_broadcaster_package = $row->is_broadcaster_package;
               

                if($alacarte == '1'){
                   $packageList_ala[]=$row;

               }
               else if($is_base_package == '1'){
                   $packageList_base[]=$row;

               }
               else if($is_broadcaster_package == '1'){
                   $packageList_broadcaster[]=$row;

               }
               else{
                   $packageList_addon[]=$row;
               }
            }
        }
        else
        {
            $statusCode = 1;
            $statusMessage = 'No records found.';
            //$packageList[0] = (object)array('packageId'=>'','packageName'=>'');
        }
        }
        else
        {
            $statusCode = 1;
            $statusMessage = 'Dealer Or Employee does not Exist.';
            //$packageList[0] = (object)array('packageId'=>'','packageName'=>'');
        }
        //echo "<pre>";
        //print_r(array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'packageList_base'=>$packageList_base,'packageList_addon'=>$packageList_addon,'packageList_ala'=>$packageList_ala,'packageList_broadcaster'=>$packageList_broadcaster));exit;
        $response = array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'packageList_base'=>$packageList_base,'packageList_addon'=>$packageList_addon,'packageList_ala'=>$packageList_ala,'packageList_broadcaster'=>$packageList_broadcaster);
        $this->sendResponse($response);
               
        }
                catch(Exception $e)
                        {
                            $this->error_res($e, 200);
                        }
        }
       
       
    /**
    * get Unassigned Packages split soap to rest conversion
    * @author soujanya 7-7-2023
    * @params {"customerId":7191,"boxNumber":"22619080127534"}
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'packageList_base'=>$packageList_base,'packageList_addon'=>$packageList_addon,'packageList_ala'=>$packageList_ala,'packageList_broadcaster'=>$packageList_broadcaster)
    */  
public function getUnassignedPackages_splitRest_post()
    { 

        
    try {
         $statusCode = 1;
        $statusMessage = '';
        //validations start
                $validation_fields=['customerId'=>['isInteger','Customer ID'],'boxNumber'=>['isString','Box Number']];
                $validation_response_array =$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                if(count($validation_response_array) > 0){  
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
        //Validation end
        $this->load->model(array('NewCustomerWithStbModel','WsModel','Customer_billing_model','Service_duration_model'));
        $obj = new WsModel();
        $employeeId = $this->getEmployeeId();
        $dealerId = $this->getDealerId();
        $customerId=trim($this->payload->customerId);
        $boxNumber=trim($this->payload->boxNumber);
        $deactivate_customerservices=array();   // Newly Added by srikanth/rajesh
        $packageList_base = array();
        $packageList_addon = array();
        $packageList_ala = array();
        $packageList_broadcaster = array();
        $stock_id =0;       
        $start_date = date('Y-m-d');
        $int_plugin_id = 4;
                if($employeeId != 0 && $dealerId != 0)
                {
                        

                    $str_intra_lco_customer_id = $customerId;
                        $arr_intra_lco_customer_id = $this->Customer_billing_model->getIntraLCOCustomer($customerId,$start_date);
                        if(is_array($arr_intra_lco_customer_id) && count($arr_intra_lco_customer_id)>0){ 
                            $str_intra_lco_customer_id = implode(',', $arr_intra_lco_customer_id); 
                        } else {}
                  

                        $stokDetails = $obj->stockDetails($boxNumber);
                        $resultArr = array();
                        if (!empty($stokDetails)) {
                            $stock_id = $stokDetails->stock_id;
                            $backend_setup_id = $stokDetails->backend_setup_id;
                            $stb_type_id = $stokDetails->stb_type_id;
                            $str_product_list = "";
                            $res = $obj->getcustomerservices_split($customerId,$boxNumber,$dealerId);
                            if(!empty($res)){
                                foreach ($res as $row) {
                                    $str_product_list .= $row->product_id.",";
                                }
                                $str_product_list = substr($str_product_list, 0, -1);
                            }
                            $resultArr = $this->NewCustomerWithStbModel->get_customerservice_products($customerId, $backend_setup_id, $str_product_list, $dealerId, $stb_type_id, $stock_id, $userType="RESELLER", $setting_value=1, $employeeId, $sort_order_val=1, $flag=0,$plugin_id=4);
                        }
                        
                       // write_to_file("--------------- resultArr ------------".json_encode($resultArr));
                        if(!empty($resultArr))
                        {
                            $statusCode = 0;
                            $statusMessage = 'Success';
                            $recurring_replaced_boxes = [];
                            $onetime_replaced_boxes = [];
                            foreach ($resultArr as $key => $value) {
                                /*
                                    Not availabe is_taxble,tax1 to tax6,broadcaster_id


                                */
                                 
                                $alacarte = $value->alacarte;
                                $is_base_package = $value->is_base_package;
                                $is_broadcaster_package = $value->is_broadcaster_package;
                                $json_rule_set_info = isset($value->rule_set_info)?$value->rule_set_info:'';
                                $arr_rule_set_info= !empty($json_rule_set_info)?json_decode($json_rule_set_info):[];
                                $obj_rule_set = isset($arr_rule_set_info->RuleSetType)?$arr_rule_set_info->RuleSetType:[];
                                $obj_bill_types = isset($obj_rule_set[0]->bill_type)?$obj_rule_set[0]->bill_type:[];
                                $obj_billing_schedule = isset($obj_rule_set[1]->billing_schedule)?$obj_rule_set[1]->billing_schedule:[];
                                $obj_service_duration = isset($obj_rule_set[2]->service_duration)?$obj_rule_set[2]->service_duration:[];

                                if(isset($obj_bill_types[0]->bill_type_attributes) && isset($obj_billing_schedule[0]->billing_schedule_attributes) && isset($obj_service_duration[0]->service_duration_attributes)){
                                    $value->bill_types        = $obj_bill_types[0]->bill_type_attributes;
                                    $value->bill_type_target_level      = $obj_bill_types[0]->target_level_name;
                                    $value->billing_schedules = $obj_billing_schedule[0]->billing_schedule_attributes;
                                    $value->billing_schedule_target_level = $obj_billing_schedule[0]->target_level_name;
                                    $value->service_durations = $obj_service_duration[0]->service_duration_attributes;
                                    $value->service_duration_target_level = $obj_service_duration[0]->target_level_name;
                                    $value->billing_schedule_name = isset($value->billing_schedules[0]->billing_schedule_name)?$value->billing_schedules[0]->billing_schedule_name:[];
                                    $value->billing_schedule_id = isset($value->billing_schedules[0]->billing_schedule_id)?$value->billing_schedules[0]->billing_schedule_id:0;
                                    
                                    $default_duration_name = '';
                                    
                                    // Ensure service_durations is sorted by quantity in ascending order
                                        usort($value->service_durations, function ($a, $b) {
                                            $quantityA = isset($a->RuleSetTransAttrib[0]->quantity) ? $a->RuleSetTransAttrib[0]->quantity : 0;
                                            $quantityB = isset($b->RuleSetTransAttrib[0]->quantity) ? $b->RuleSetTransAttrib[0]->quantity : 0;
                                            return $quantityA <=> $quantityB; // Ascending order
                                        });
            
                                        foreach ($value->service_durations as $service_duration) {
                                            if (isset($service_duration->default) && $service_duration->default == '1') {
                                                $default_duration_name = $service_duration->customer_service_duration_name;
                                                $ruleSetTransAttrib = $service_duration->RuleSetTransAttrib;
            
                                                if ('Longstanding' == $default_duration_name) {
                                                    // No quantity selection for longstanding
                                                    $duration_fix = isset($ruleSetTransAttrib[0]->duration_limit) ? $ruleSetTransAttrib[0]->duration_limit : 1;
                                                } elseif ('Months' == $default_duration_name) {
                                                    // In case of months, number of months for the service will be selected
                                                    $duration_fix = isset($ruleSetTransAttrib[0]->quantity) ? $ruleSetTransAttrib[0]->quantity : 1;
                                                } elseif ('Days' == $default_duration_name) {
                                                    // In case of days, number of days for the service will be selected
                                                    $duration_fix = isset($ruleSetTransAttrib[0]->quantity) ? $ruleSetTransAttrib[0]->quantity : 1;
                                                } else {
                                                    $duration_fix = 1;
                                                }
                                                break;
                                            }
                                        }
            
            
                                        // Replacement conditions will be added for only CAS and OTT plugin
                                    // getting old stock id if any replacement is done in current month for current stock id
                                   
                                    if(4 == $int_plugin_id && $customerId > 0 && $stock_id > 0) 
                                    {
                                        $int_str_old_stock_id = $stock_id;
                                        if(1==$value->billing_schedule_id){ // Recurring/Monthly
                                            if(empty($recurring_replaced_boxes)){
                                                $recurring_replaced_boxes = $this->Customer_billing_model->getReplacedBoxes($str_intra_lco_customer_id,$stock_id,$value->billing_schedule_id,$start_date);
                                            }
                                            if(is_array($recurring_replaced_boxes) && !empty($recurring_replaced_boxes)){ 
                                                $int_str_old_stock_id = implode(',', $recurring_replaced_boxes); 
                                            } else {}
                                        }
                                        else{ // Onetime
                                            if(empty($onetime_replaced_boxes)){
                                                $onetime_replaced_boxes = $this->Customer_billing_model->getReplacedBoxes($str_intra_lco_customer_id,$stock_id,$value->billing_schedule_id,$start_date);
                                            }
                                            if(is_array($onetime_replaced_boxes) && !empty($onetime_replaced_boxes)){ 
                                                $int_str_old_stock_id = implode(',', $onetime_replaced_boxes); 
                                            } else {}
                                        }
                                        $extra_parameters['replaced_box_stock_id'] = $int_str_old_stock_id;
                                    }
                                    else{
                                        $extra_parameters['replaced_box_stock_id'] = $stock_id;
                                    }
                                    
                                    
                                    $extra_parameters['stock_id'] = $stock_id;
                                    $extra_parameters['int_plugin_id'] = 4;
                                    
                                    $value->default_end_date = $this->Service_duration_model->get_package_end_date($dealerId,$start_date,$arr_rule_set_info->ProductId,$value->billing_schedule_id,$default_duration_name, $duration_fix,$extra_parameters);
       
                                    unset($value->rule_set_info);
                                }
                                else{
                                    unset($value->rule_set_info);
                                    continue;
                                }

                                $originalDate = $value->default_end_date;
                                $formattedDate = date('d-m-Y', strtotime($originalDate));
             
                                
                                //$broadcaster_id = $row->broadcaster_id;
                                if($is_broadcaster_package == '1' && isset($value->broadcaster_id) && $value->broadcaster_id > 0){
                                    $packageList_broadcaster[] = array("product_id"=>$value->product_id,"pname"=>$value->pname,"base_price"=>$value->base_price,"sd_channels_count"=>$value->sd_channels_count,"hd_channels_count"=>$value->hd_channels_count,"is_base_package"=>$value->is_base_package,"is_broadcaster_package"=>$value->is_broadcaster_package,"alacarte"=>$value->alacarte,
                                    "monthly_or_yearly"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->customer_service_duration_name,
                                    "validity"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->quantity,
                                    "validity_days"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->duration_limit,
                                    'pricing_structure_type'=>2,"is_taxble"=>0,"tax1"=>0,"tax2"=>0,"tax3"=>0,"tax4"=>0,"tax5"=>0,"tax6"=>0,"broadcaster_id"=>0,"end_date"=>$formattedDate);
                                }
                                else if($is_base_package == '1'){
                                    $packageList_base[] = array("product_id"=>$value->product_id,"pname"=>$value->pname,"base_price"=>$value->base_price,"sd_channels_count"=>$value->sd_channels_count,"hd_channels_count"=>$value->hd_channels_count,"is_base_package"=>$value->is_base_package,"is_broadcaster_package"=>$value->is_broadcaster_package,"alacarte"=>$value->alacarte,
                                    "monthly_or_yearly"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->customer_service_duration_name,
                                    "validity"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->quantity,
                                    "validity_days"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->duration_limit,
                                    'pricing_structure_type'=>2,"is_taxble"=>0,"tax1"=>0,"tax2"=>0,"tax3"=>0,"tax4"=>0,"tax5"=>0,"tax6"=>0,"broadcaster_id"=>0,"end_date"=>$formattedDate);
                                }
                                else if($alacarte == '1'){
                                    $packageList_ala[] = array("product_id"=>$value->product_id,"pname"=>$value->pname,"base_price"=>$value->base_price,"sd_channels_count"=>$value->sd_channels_count,"hd_channels_count"=>$value->hd_channels_count,"is_base_package"=>$value->is_base_package,"is_broadcaster_package"=>$value->is_broadcaster_package,"alacarte"=>$value->alacarte,
                                    "monthly_or_yearly"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->customer_service_duration_name,
                                    "validity"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->quantity,
                                    "validity_days"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->duration_limit,
                                    'pricing_structure_type'=>2,"is_taxble"=>0,"tax1"=>0,"tax2"=>0,"tax3"=>0,"tax4"=>0,"tax5"=>0,"tax6"=>0,"broadcaster_id"=>0,"end_date"=>$formattedDate);
                                }
                                else{
                                    
                                    $packageList_addon[] = array("product_id"=>$value->product_id,
                                    "pname"=>$value->pname,
                                    "base_price"=>$value->base_price,
                                    "sd_channels_count"=>$value->sd_channels_count,
                                    "hd_channels_count"=>$value->hd_channels_count,
                                    "is_base_package"=>$value->is_base_package,
                                    "is_broadcaster_package"=>$value->is_broadcaster_package,
                                    "alacarte"=>$value->alacarte,
                                    "monthly_or_yearly"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->customer_service_duration_name,
                                    "validity"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->quantity,
                                    "validity_days"=>$arr_rule_set_info->RuleSetType[2]->service_duration[0]->service_duration_attributes[0]->RuleSetTransAttrib[0]->duration_limit,
                                    'pricing_structure_type'=>2,
                                    "is_taxble"=>0,
                                    "tax1"=>0,"tax2"=>0,"tax3"=>0,"tax4"=>0,"tax5"=>0,"tax6"=>0,"broadcaster_id"=>0,
                                    "end_date"=>$formattedDate);
                                }
                                /*
                                $product_data_array[$key] = array("product_id"=>$value->product_id,"name"=>$value->pname,"base_price"=>$value->base_price,"sd_channels_count"=>$value->sd_channels_count,"hd_channels_count"=>$value->hd_channels_count,"is_base_package"=>$value->is_base_package,"is_broadcaster_package"=>$value->is_broadcaster_package,"alacarte"=>$value->alacarte,"monthly_or_yearly"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes'][0]['customer_service_duration_name'],"validity"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes'][0]['customer_service_duration_name'],"validity_days"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes'][0]['RuleSetTransAttrib'][0]['duration_limit'],'pricing_structure_type'=>2,"is_taxble"=>0,"tax1"=>0,"tax2"=>0,"tax3"=>0,"tax4"=>0,"tax5"=>0,"tax6"=>0,"broadcaster_id"=>0);
                                */
                                
                            }

                           

                        }
                }
                else
                {
                        $statusMessage = 'No records found.';
                        //$packageList[0] = (object)array('packageId'=>'','packageName'=>'');
                }
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'packageList_base'=>$packageList_base,'packageList_addon'=>$packageList_addon,'packageList_ala'=>$packageList_ala,'packageList_broadcaster'=>$packageList_broadcaster,'deactivate_customerservices'=>$deactivate_customerservices);
                $this->sendResponse($response);

        }        

        catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
    }



 
    /**
    * channel_list soap to rest conversion
    * @author soujanya 7-7-2023
    * @params product_id 637, dealer_id 1
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'channel_details'=>$channel_details)
    */  
public function channel_listRest_post()
{ try {
         $statusCode = 1;
		$statusMessage = '';
    //validations start
                $validation_fields=['dealer_id'=>['isInteger','Dealer ID'],'product_id'=>['isInteger','Product ID']];
                $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                if(count($validation_response_array) > 0){  
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }

    //Validation end
        $obj = new WsModel();
        $employeeId = $this->getEmployeeId();
        $dealer_id=trim($this->payload->dealer_id);
        $product_id=trim($this->payload->product_id);
        $channel_details=array();
   
        if($employeeId != 0 && $dealer_id != 0)
        {
                $channel_list = $obj->getchannellist($dealer_id,$product_id);
                //if(count($channel_list)>0)
                if(!empty($channel_list))
                {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        foreach($channel_list as $k=>$v)
                        {
                                $channel_details[$k]=$v;
                        }
                }
                else{
                        $statusMessage = 'Empty channel list';
                }
        }
        else{
                $statusMessage = 'Not a valid customer';
        }

      
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'channel_details'=>$channel_details);
        $this->sendResponse($response);
}
  catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
}


	



  /**
    * Complaint Categories soap to rest conversion
    * @author Rajesh 24-Dec-2021
    * @params void
    * @return arrayarray('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaintCategories'=>$complaintCategoriesList)
    */
public function complaintCategoriesRest_post()
{ 
                    try {
		$obj = new WsModel();
		$employeeId = $this->getEmployeeId(); 
                                $dealerId = $this->getDealerId();
     
		if($employeeId != 0 && $dealerId != 0)
		{
			$res = $obj->getcomplaint_category($dealerId,$flag=0);
			$complaintCategoriesList = array();
			if(count($res)>0)
			{
				$statusCode = 0;
				$statusMessage = 'Success';
				foreach($res as $k=>$v)
				{
					$complaintCategoriesList[$k]=$v;
				}
			}
			else
			{
				$statusCode = 1;
				$statusMessage = 'No records found.';
				$complaintCategoriesList[0] = (object)array('categoryId'=>'','categoryName'=>'');
			}
		}
		else
		{
			$statusCode = 1;
			$statusMessage = 'No records found.';
			$complaintCategoriesList[0] = (object)array('categoryId'=>'','categoryName'=>'');
		}
              
		$response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaintCategories'=>$complaintCategoriesList);	
                                $this->sendResponse($response);
	}	
                catch(Exception $e)
                {

                    $this->error_res($e, 200);
                }
        }




  /**
    * Complaint Types soap to rest conversion
    * @author Rajesh 27-Dec-2021
    * @params void
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessaget)
    */
public function complaintTypesRest_post()
{ try {
        $obj = new WsModel();
		$this->load->model('Simplecomplaints_model');
           $simplecomplaintsModel = new Simplecomplaints_model();
        //Get the dealer_id and employee_id from auth token
        $employeeId = $this->getEmployeeId(); 
        $dealerId = $this->getDealerId();
		$ticket_closer_categories_data=array();
        if($employeeId != 0 && $dealerId != 0)
        {
                $res = $obj->getComplaintTypes($dealerId);
				$ticket_closer_categories=$simplecomplaintsModel->complaintCategory($dealerId,$from_mobile_app=1);
			if(!empty($ticket_closer_categories)){
				foreach ($ticket_closer_categories as $key => $value) {
					$ticket_closer_categories_data[] = array("category_id"=>$value['category_id'],"parent_category_id"=>$value['parent_category_id'],"category_name"=>$value['category_name'],"sub_category_name"=>$value['sub_category_name']);
					//$ticket_closer_categories_data[] = array("category_id"=>$value['category_id']);
				}
			}
                $complaintTypeList = array();
                if(count($res)>0)
                {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        foreach($res as $k=>$v)
                        {
                                $complaintTypeList[$k]=$v;
                        }
                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = 'No records found.';
                        $complaintTypeList[0] = (object)array('statusName'=>'');
                }
        }
        else
        {
                $statusCode = 1;
                $statusMessage = 'No records found.';
                $complaintTypeList[0] = (object)array('statusName'=>'');
        }
       
         $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaintStatuses'=>$complaintTypeList,'ticket_closer_categories'=>$ticket_closer_categories_data);	
         $this->sendResponse($response);
}       catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
              }
}

  /**
    * Complaint Types soap to rest conversion
    * @author soujanya 7-7-2023
    * @params customer_id 7926, dealer_id 1
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessaget)
    */
public function ComplaintHistoryRest_post(){
    try {
             $statusCode = 1;
		$statusMessage = '';
           //validations start
                $validation_fields=['dealer_id'=>['isInteger|isRequired','Dealer ID'],'customer_id'=>['isInteger|isRequired','Customer Id']];
                $validation_response_array =$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                if(count($validation_response_array) > 0){  
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
          //Validation end
        
      $obj = new WsModel();
      $dealer_id=trim($this->payload->dealer_id);
      $customer_id=trim($this->payload->customer_id);
      //$dealerId = $this->getDealerId();
      $employeeId = $this->getEmployeeId(); 
      $complaint_details=array();
    
      if($employeeId != 0 && $dealer_id != 0 && $customer_id != 0)
              {
                      $response_details=$obj->Complaint_list_Service($dealer_id,$customer_id);
                      if(count($response_details)>0)
                      {
                              $statusCode = 0;
                              $statusMessage = 'Success';
                              foreach($response_details as $k=>$v)
                              {
                                      $complaint_details[$k]=$v;
                              }
                      }
                      else{
                              $statusMessage = 'Empty payment list';
                      }
              }
              else{
                      $statusMessage = 'Not a valid customer';
              }
   
              $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaint_details'=>$complaint_details);
              $this->sendResponse($response);
         
  } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
              }
}

  /**
    * Payment Service soap to rest conversion
    * @author soujanya 7-7-2023
    * @params dealer_id 1, customer_id 3014
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessaget,'payment_details'=>$payment_details)
    */
   public function PaymentServiceRest_post(){
       try {
                $statusCode = 1;
		$statusMessage = '';
           //validations start
                $validation_fields=['dealer_id'=>['isInteger','Dealer ID'],'customer_id'=>['isInteger','Customer Id']];
                $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                if(count($validation_response_array) > 0){  
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
          //Validation end
        $obj = new WsModel();
        $dealer_id=trim($this->payload->dealer_id);
        $customer_id=trim($this->payload->customer_id);
        $employeeId = $this->getEmployeeId(); 
        $payment_details=array();

        if($employeeId != 0 && $dealer_id != 0 && $customer_id != 0)
		{
			$response_details=$obj->Payment_list_Service($dealer_id,$customer_id);
			if(count($response_details)>0)
			{
				$statusCode = 0;
				$statusMessage = 'Success';
				foreach($response_details as $k=>$v)
				{
					$payment_details[$k]=$v;
				}
			}
			else{
				//$statusCode = 1;
				$statusMessage = 'Empty payment list';
			}
		}
		else{
			//$statusCode = 1;
			$statusMessage = 'Not a valid customer';
		}
        
		$response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'payment_details'=>$payment_details);
                $this->sendResponse($response);
                
    } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
              }
}


    /**
    * emp Customer Collection Details soap to rest conversion
    * @author soujanya 7-7-2023
    * @params dealer_id 1 fromDate 2021-07-04 toDate 2021-07-04
    * @return array('status_code' => $statusCode, 'status_msg' => $statusMessage, 'collectionList' => $collectionList);
    */

public function empCustomerCollectionDetailsRest_post() {
try{

$dealerId=trim($this->payload->dealer_id);
$fromDate=isset($this->payload->fromDate)?trim(date('Y-m-d',strtotime($this->payload->fromDate))):date('Y-m-01');
$toDate=isset($this->payload->toDate)?trim(date('Y-m-d',strtotime($this->payload->toDate))):date('Y-m-t');
$customerInfo = (object)array('fromDate'=>$fromDate, 'toDate'=>$toDate);
$validation_fields=['dealer_id'=>['isInteger','Dealer Id'],'fromDate'=>['checkValidDate','From Date'],'toDate'=>['checkValidDate','To Date']];
$validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
if(count($validation_response_array) > 0){  
    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
    $response = array(  'status_code'=>$statusCode,
                        'status_msg'=>$statusMessage
                    );
    $this->sendResponse($response);
}
$employeeId = $this->getEmployeeId();
        $obj = new WsModel();
        $collectionList = array();
      
        if ($employeeId > 0 && $dealerId > 0) {
                $access = $obj->accessControl($employeeId, $dealerId);
                $userType = $obj->getUserType($employeeId,$dealerId);
                //write_to_file(json_encode($access));
                if (!empty($access) > 0 && $access->COLLECTIONS->view == 1) {
                        $result = $obj->getEmployeeCustomerCollectionDetails($customerInfo, $employeeId, $dealerId,$userType );
                        write_to_file(" ============ getEmployeeCustomerCollectionDetails query ========== ".$this->db->last_query());
                        if (!empty($result)) {
                                $statusCode = 0;
                                $statusMessage = 'Success';
                                foreach ($result as $k => $v) {
                                        $collectionList[$k] = $v;
                                }
                                //$collectionList = $result;
                        } else {
                                //$statusCode = 1;
                                $statusMessage = 'No records found.';
                                $collectionList[0] = (object) array('customerName' => '', 'lcoCustomerId' => '', 'paymentDate' => '', 'paymentMode' => '', 'amount' => '');
                        }
                } else {
                        //$statusCode = 1;
                        $statusMessage = 'No records found.';
                        $collectionList[0] = (object) array('customerName' => '', 'lcoCustomerId' => '', 'paymentDate' => '', 'paymentMode' => '', 'amount' => '');
                }
        } else {
                //$statusCode = 1;
                $statusMessage = 'No records found.';
                $collectionList[0] = (object) array('customerName' => '', 'lcoCustomerId' => '', 'paymentDate' => '', 'paymentMode' => '', 'amount' => '');
        }
      


            $response = array('status_code' => $statusCode, 'status_msg' => $statusMessage, 'collectionList' => $collectionList);
            // print_r($response);
            // exit;
            $encry_response = $this->encryption_lib->app_data_encryption($response);
            $this->response($encry_response, 200);
}
catch(Exception $e)
{
     $this->error_res($e, 200);
}
}



  /**
    * get Customer Complaint List soap to rest conversion
    * @author soujanya 7-7-2023
    * @params altCustomerId 8224
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerComplaintList'=>$customerComplaints)
    */
public function getCustomerComplaintListRest_post()
{ try {
    //validations start
    $statusCode=1;
    $statusMessage='';
        $validation_fields=array();
                //$validation_fields=['altCustomerId'=>['isInteger','Alt Customer ID'],'status'=>['isString','Stutus']];
        $customerId = isset($this->payload->altCustomerId) ? $this->payload->altCustomerId : 0;
        if(!empty($CustomerId)){
        $validation_fields['altCustomerId']=['isInteger','Alt Customer Id'];
         }
         
         $status = isset($this->payload->status) ? $this->payload->status : '';
         if(!empty($status)){
         $validation_fields['status']=['isString','Status'];
         }
         
         $userType = isset($this->payload->userType) ? $this->payload->userType : '';
        if(!empty($userType)){
        $validation_fields['userType']=['isString','User Type'];
         }
    
         $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
         if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }


    //Validation end
      //  write_to_file("com list");
        $obj = new WsModel();
        $this->load->model('Simplecomplaints_model');
        $objComplaints = new Simplecomplaints_model();
        $customerName='';
        $ticketNo='';
        $startDate='';
        $endDate='';
        
        $customerGroup='';
        $compalintAgeingHours='';
        $complaintCategory='';
        $withIn='';
        $closedWithIn='';
        $userId='';
        $assineduserId='';
        $from_dashboard=0;
        $installation_address='';
        $stb_type=0;
//        $userType = '';
//        $status = '';
        //Get the dealer_id and employee_id from auth token
        $employeeId = $this->getEmployeeId();
        $dealerId = $this->getDealerId();

        if($employeeId != 0 && $dealerId != 0)
        {
                $access = $obj->accessControl($employeeId,$dealerId);
                if(!empty($access) > 0 && $access->COMPLAINTS->view == 1)
                {
//                        $customerId =$this->payload->altCustomerId;
//                        $status =$this->payload->status;
//                        $userType =$this->payload->userType;

        //write_to_file("status@controller - ".$status);
                        if($customerId != '' || $status!='')
                        {
                                //$result = $obj->getCustomerComplaintList($customerId,$employeeId,$dealerId,$status);
                                $result = $objComplaints->listcomplain($st=0,$pp=0,$dealerId,$customerId,$customerName='',$ticketNo='',$status,$startDate='',$endDate='',$customerGroup='-1',$compalintAgeingHours='',$complaintCategory='-1',$withIn='',$closedWithIn='',$userId=0,$assineduserId=0,$from_dashboard=0,$installation_address='',$stb_type=0,$userType,$employeeId);
            //write_to_file("count - ".count($result));
                                $customerComplaints = array();
                                if(count($result)>0)
                                {                                            
                                        $statusCode = 0;
                                        $statusMessage = 'Success';
                                        foreach($result as $key=>$value)
                                        {
                                                $customerComplaints[$key] = $value;
                                        }
                                }
                                else
                                {
                                        $statusCode = 1;
                                        $statusMessage = 'No records found.';
                                        $customerComplaints[0]=(object)array('customerId'=>'','customNumber'=>'','customerName'=>'','group'=>'','complaintId'=>'','ticketNumber'=>'','complaint'=>'','complaintTime'=>'','status'=>'');
                                }
                        }
                        else
                        {
                                $statusMessage = 'No records found.';
                                $customerComplaints[0]=(object)array('customerId'=>'','customNumber'=>'','customerName'=>'','group'=>'','complaintId'=>'','ticketNumber'=>'','complaint'=>'','complaintTime'=>'','status'=>'');
                        }
                }
                else
                {
                        $statusMessage = 'No records found.';
                        $customerComplaints[0]=(object)array('customerId'=>'','customNumber'=>'','customerName'=>'','group'=>'','complaintId'=>'','ticketNumber'=>'','complaint'=>'','complaintTime'=>'','status'=>'');
                }
        }
        else
        {
                $statusMessage = 'Dealer or Employee does not exist';
                $customerComplaints[0]=(object)array('customerId'=>'','customNumber'=>'','customerName'=>'','group'=>'','complaintId'=>'','ticketNumber'=>'','complaint'=>'','complaintTime'=>'','status'=>'');
        }
   
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerComplaintList'=>$customerComplaints);
        write_to_file("---------------- listcomplain ------------- ".json_encode($response));
        // print_r( $response);
        // exit;

        $encry_response = $this->encryption_lib->app_data_encryption($response);
        $this->response($encry_response, 200);

}  catch(Exception $e)
        {

            $this->error_res($e, 200);
        }
}



     /**
     * get groups soap to rest conversion
     * @author soujanya 7-7-2023
     * @params {"serialNumber":"23120370003930"}// serialNumber
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'groupsList'=>$groupsList)
    */
public function getGroupsRest_post(){   // auth-token 5fb9ea11df0697.51848119
    try
    {
        $statusCode = 1;
        $groupsList = array();
        $statusMessage='';
        //validations
        $validation_fields=['serialNumber'=>['isString','Serial Number']];
        
        $validation_response_array =$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
          //Validation end
                $serialNumber=trim($this->payload->serialNumber);
               
                $this->load->model('WsModel');  
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
            
                if($employeeId > 0 && $dealerId > 0)
                {

                        $res = $this->WsModel->getResellerGroup($dealerId,$employeeId,$serialNumber); //Int
                        if(!empty($res))
                        {
                                $statusCode = 0;
                                $statusMessage = 'Success';
                                foreach($res as $k=>$v)
                                {
                                        $groupsList[$k]=$v;
                                }

                        }
                        else
                        {
                                $statusMessage = 'No records found.';
                        }
               
                }else
                {
                                       $statusMessage = 'Dealer or Employee does not exist';  
                }
            
               
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'groupsList'=>$groupsList);
                // print_r($response);
                // exit;
                $encry_response = $this->encryption_lib->app_data_encryption($response);
                $this->response($encry_response, 200);
        }
        catch(Exception $e)
        {

            $this->error_res($e, 200);
        }
}

    /**
     * get customer types soap to rest conversion
     * @author RameshDudala 21-Dec-2021/
     * @params {"stateId":"82"}// stateId integer
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerTypeList'=>$customerTypeList)
    **/
public function getCustomerTypesRest_post(){   // auth-token 5fb9ea11df0697.51848119
    try
    {
        $statusCode = 1;
        $customerTypeList = array();
        $statusMessage='';
      
                $this->load->model('WsModel');  
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
        
         //Code added by Ramya for Commercial Customer /LCO concept  on October 23 2025 start
                    $this->load->model('NewCustomerWithStbModel');
                    $int_sess_enable_commercial_lco =$this->WsModel->getLovValue('ENABLE_COMMERCIAL_LCO',$dealerId);
                    $int_employee_type_id = 0;
                    if(isset($int_sess_enable_commercial_lco) && $int_sess_enable_commercial_lco == 1){
                        //get employee type data
                        $array_employee_type_details = $this->NewCustomerWithStbModel->getEmployeeCommercialTypeData($employeeId);
                        if(!empty($array_employee_type_details)){
                            $int_employee_type_id = isset($array_employee_type_details[0]->employee_type_id) ? $array_employee_type_details[0]->employee_type_id : 0;
                        }
                    }
                    //Code added by Ramya for Commercial Customer /LCO concept  on October 23 2025 end

                if($employeeId > 0 && $dealerId > 0)
                {
                  
                  if(isset($int_sess_enable_commercial_lco) && $int_sess_enable_commercial_lco == 1){
                    $res = $this->WsModel->get_customer_type($int_employee_type_id); //Int
                  } else{
                    $res = $this->WsModel->get_customer_type(); //Int
                  }      
               

if(!empty($res))
{
$statusCode = 0;
$statusMessage = 'Success';
foreach($res as $k=>$v)
{
$customerTypeList[$k]=$v;
}
}
else
{

$statusMessage = 'No records found.';

}
               
                }else
                {
                                       $statusMessage = 'Dealer or Employee does not exist';  
                }
              
               
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'customerTypeList'=>$customerTypeList);
                $encry_response = $this->encryption_lib->app_data_encryption($response);
                $this->response($encry_response, 200);
                }
                catch(Exception $e)
                {
                   
                    $this->error_res($e, 200);
                }
        }

     /**
     * get mandals soap to rest conversion
     * @author soujanya 10-7-2023
     * @params {"districtId182"}// districtId integer
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'mandalList'=>$mandalList)
    **/
 public function getmandalsRest_post()
 {

       try
       {  
        $statusCode = 1;
        $mandalList = array();
        $statusMessage='';
        //validations
        $validation_fields=['districtId'=>['isInteger','District Id']];
        $validation_response_array =$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
          //Validation end
         
                $districtId=trim($this->payload->districtId);
                $this->load->model('WsModel');  
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
        
                if($employeeId > 0 && $dealerId > 0)
                {
                         
               
$res = $this->WsModel->getmandals($districtId); //Int
if(!empty($res))
{
$statusCode = 0;
$statusMessage = 'Success';
foreach($res as $k=>$v)
{
$mandalList[$k]=$v;
}
}
else
{

$statusMessage = 'No records found.';

}
               
                }else
                {
                                       $statusMessage = 'Dealer or Employee does not exist';  
                }
               
               
                $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'mandalList'=>$mandalList);
               
                $encry_response = $this->encryption_lib->app_data_encryption($response);
                $this->response($encry_response, 200);
               
        } catch(Exception $e)
             {
                   
                $this->error_res($e, 200);
              }
}
   

  /**
     * API service:extendCustomerServices
     * @author RameshDudala 24-Dec-2021
     * @params {"customer_id:Integer,"product_id":Integer,"stock_id"=>Integer,"login_employee_id"=>Integer,"quantity"=>Integer,"fromMobileApp"=>Integer}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/

public function extendCustomerServices_post()
{ 
   try{ 
        $statusCode=1;
        $errorCode='0000';
        $statusMessage = '';
        
        $int_customer_id=0;
        $product_id=0;
        $stock_id=0;
        $login_employee_id=0;
        $quantity=0;
        $fromMobileApp=0;
          //validations
         $validation_fields=array();
         if(isset($this->payload->customer_id) && !empty($this->payload->customer_id)){
         $validation_fields['customer_id']=['isInteger','Customer Id'];
         $int_customer_id=$this->payload->customer_id;
         }
         if(isset($this->payload->product_id) && !empty($this->payload->product_id)){
         $validation_fields['product_id']=['isInteger','Product Id'];
         $product_id=$this->payload->product_id;
         }
         if(isset($this->payload->stock_id) && !empty($this->payload->stock_id)){
         $validation_fields['stock_id']=['isInteger','Stock id'];
         $stock_id=trim($this->payload->stock_id);
         }
     
        if(isset($this->payload->quantity) && !empty($this->payload->quantity)){
         $validation_fields['quantity']=['isInteger','Quantity'];
         $quantity=trim($this->payload->quantity);
         }
         if(isset($this->payload->fromMobileApp) && !empty($this->payload->fromMobileApp)){
         $validation_fields['fromMobileApp']=['isInteger','From Mobile App'];
         $fromMobileApp=trim($this->payload->fromMobileApp);
         }
         $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
         write_to_file(" ============== service_extension validation_response_array ======== ".json_encode($validation_response_array));
         if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
          //Validation end
         
         
            $int_login_employee_id = $this->getEmployeeId();
            $int_dealer_id = $this->getDealerId();

            if ($int_login_employee_id > 0 && $int_dealer_id > 0) {
                
         $int_customer_service_id = isset($this->payload->customer_service_id) ?$this->payload->customer_service_id :0;
        $date_extend_date = isset($this->payload->extend_date) ?$this->payload->extend_date :'';
        
        $plugin_id = isset($this->payload->plugin_id) ?$this->payload->plugin_id :0;
        
                $this->load->model('CustomersModel');
            $int_reseller_id=$this->CustomersModel->getReseller_id($int_dealer_id, $int_customer_id);
            write_to_file(" ============== service_extension int_reseller_id ======== ".json_encode($int_reseller_id));
                $str_login_users_type = '';
                    $str_login_employee_parent_type = '';
                    $int_login_employee_parent_id = 0;
                    $str_username = '';
                    $str_first_name = '';
                    $str_last_name = '';
                 
                 $this->load->model('WsModel');

                $userDetails = $this->WsModel->getusersDetails($int_dealer_id, $int_login_employee_id);
                write_to_file(" ============== service_extension userDetails ======== ".json_encode($userDetails));
                if (!empty($userDetails)) {
                    $str_login_users_type = $userDetails->users_type;
                    $str_login_employee_parent_type = $userDetails->employee_parent_type;
                    $int_login_employee_parent_id = $userDetails->employee_parent_id;
                    $str_username = $userDetails->username;
                    $str_first_name = $userDetails->first_name;
                    $str_last_name = $userDetails->last_name;
                }
                //Dealer Settings
                $array_dealer_setting = array();
                $this->load->library('LovModel');
                $dealrSettings = $this->LovModel->setDealerSettings($int_dealer_id);
                if (!empty($dealrSettings)) {
                    $array_dealer_setting = (array) $dealrSettings;
                }
           
                
     $extra_params_other['array_dealer_setting']=$array_dealer_setting;
      
        $show_for_extension = isset($array_dealer_setting['SHOW_SERVICE_EXTENSION'])?$array_dealer_setting['SHOW_SERVICE_EXTENSION']:0;
        if($show_for_extension){
                $data_for_extension = array();
                if($int_customer_service_id<=0 || $int_customer_id<=0)
                {
                   $statusMessage="Select the required fileds."   ;
                   throw new Exception($statusMessage);
                }
                $this->load->model('Process_Model');
                $this->load->library('service_extension_lib');
               write_to_file(" ============== service_extension int_customer_service_id ======== ".json_encode($int_customer_service_id));
               write_to_file(" ============== service_extension plugin_id ======== ".json_encode($plugin_id));
               write_to_file(" ============== service_extension date_extend_date ======== ".json_encode($date_extend_date));
               write_to_file(" ============== service_extension int_customer_id ======== ".json_encode($int_customer_id));
               
               try {
                   $data_for_extension = $this->service_extension_lib->getDataForExtenstion($plugin_id=4,$date_extend_date,$int_dealer_id,$int_reseller_id,$int_customer_id,$int_customer_service_id,[],$extra_params_other);
                   str_to_file(" ============== service_extension_lib SUCCESS - data_for_extension retrieved ========".json_encode($data_for_extension) , $filename='service_extension_api');
               } catch (Exception $e) {
                   str_to_file(" ============== service_extension_lib FAILURE - Exception: " . $e->getMessage() . " File: " . $e->getFile() . " Line: " . $e->getLine(), $filename='service_extension_error');
                   str_to_file(" ============== service_extension_lib FAILURE - Stack trace: " . $e->getTraceAsString(), $filename='service_extension_error');
                 
                } catch (Error $e) {
                   str_to_file(" ============== service_extension_lib FATAL ERROR - Error: " . $e->getMessage() . " File: " . $e->getFile() . " Line: " . $e->getLine(), $filename='service_extension_error');
                   str_to_file(" ============== service_extension_lib FATAL ERROR - Stack trace: " . $e->getTraceAsString(), $filename='service_extension_error');
                   
               }
               
                write_to_file(" ============== service_extension_lib data_for_extension ======== ".json_encode($data_for_extension));
                // print_r($data_for_extension);
                $operation_name = 'service_extension_from_app';
                $int_operation_id= $this->Process_Model->getoperation_id($operation_name,$int_dealer_id);
                write_to_file(" ============== service_extension_lib int_operation_id ======== ".json_encode($int_operation_id));
                $validation_operations = array();
                $validation_operations[0] = 'service_extension_package_validations';
                $extra_parameters = array(
                    'dealer_id' => $int_dealer_id,
                    'users_type' => $str_login_users_type,
                    'login_employee_id' => $int_login_employee_id,
                    'employee_parent_type' => $str_login_employee_parent_type,
                    'employee_parent_id' => $int_login_employee_parent_id,
                    'dealer_setting' => $array_dealer_setting,
                    'int_operation_id'=>$int_operation_id,
                    'validation_operation_names'=>$validation_operations,
                    'is_service_extension'=>1,
                    'is_unpaid_temp_renew_service'=>1,// if it is 1 
                    'is_customer_temp_reason_exist'=>0, // and is 0 to  Service Renew/extention
                    'extension_remarks'=>"Service extension from LCO Mobile APP"
                );
                $arr_customer_details = array(
                    'customer_id' => $int_customer_id,
                    'reseller_id' => $int_reseller_id
                );
                $data_for_operation = array(
                    'extra_parameters' => $extra_parameters,
                    'arr_act_package_details'=>isset($data_for_extension['arr_act_package_details'])?$data_for_extension['arr_act_package_details']:array(),
                    'arr_box_details'=>isset($data_for_extension['arr_box_details'])?$data_for_extension['arr_box_details']:array(),
                    'arr_customer_details'=>$arr_customer_details,
                    'plugin_id'=>$plugin_id,
                    STATUS=>SUCCESS,
                    ERR_CODE=>'SUC_0000',
                    ERR_MSG=>'Success'
                );
                
                if(count($data_for_operation)>0)
                {
                    $this->load->library('Workflow_lib');
                    $int_operation_id = $data_for_operation['extra_parameters']['int_operation_id'];
                    $activity_id =11; // activity name = 10 service_extension_review
                                        //activity name = 11 service_extension_submit
                    //$this->load->library('Service_extension_lib');
                    //$this->service_extension_lib->doServiceExtension($data_for_operation, $action_id=3393);
                    
                    try {
                        str_to_file(" ============== workflow_lib START - executing workflow for operation_id: " . $int_operation_id . " activity_id: " . $activity_id, $filename='service_extension_workflow');
                        $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $data_for_operation);
                        str_to_file(" ============== workflow_lib SUCCESS - workflow completed successfully", $filename='service_extension_workflow');
                    } catch (Exception $e) {
                        str_to_file(" ============== workflow_lib FAILURE - Exception: " . $e->getMessage() . " File: " . $e->getFile() . " Line: " . $e->getLine(), $filename='service_extension_workflow_error');
                        str_to_file(" ============== workflow_lib FAILURE - Stack trace: " . $e->getTraceAsString(), $filename='service_extension_workflow_error');
                      
                    } catch (Error $e) {
                        str_to_file(" ============== workflow_lib FATAL ERROR - Error: " . $e->getMessage() . " File: " . $e->getFile() . " Line: " . $e->getLine(), $filename='service_extension_workflow_error');
                        str_to_file(" ============== workflow_lib FATAL ERROR - Stack trace: " . $e->getTraceAsString(), $filename='service_extension_workflow_error');
                       
                    }
                }
                write_to_file(" ============== service_extension_lib after work flow data_for_operation ======== ".json_encode($data_for_operation));
                //echo $statusMessage;
                //print_r($data_for_operation);
                if(isset($data_for_operation[STATUS]) && SUCCESS==$data_for_operation[STATUS])
                {
                   $statusCode = 0; 
                    $errorCode = $data_for_operation[ERR_CODE];
                   $statusMessage="Service extended successfully."   ;        
                }
                else
                {
                    $errorCode = $data_for_operation[ERR_CODE];
                    $statusMessage = $data_for_operation[ERR_MSG];
                }
            }
            else{
                $statusMessage = 'Extension ,Access Denied.';
            }
          }else
                {
                                       $statusMessage = 'Dealer or Employee does not exist';  
                }

       $response = array('status_code'=>$statusCode,'error_code'=>$errorCode, 'status_msg'=>$statusMessage);
                $encry_response = $this->encryption_lib->app_data_encryption($response);
                $this->response($encry_response, 200);
                
               
        } catch(Exception $e)
        {
                   
                $this->error_res($e, 200);
        }

}
    /**
     * API service:renewServicesList
     * @author RameshDudala 24-Dec-2021
     * @params {"customer_id:Integer,"customer_service_id":Integer,"product_ids"=>isString}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/
 public function renewServicesList_post()
    {       
      try{
          $statusCode=1;
          $statusMessage = '';
          //validations
         $validation_fields=array();
          if(isset($this->payload->customer_id) && !empty($this->payload->customer_id)){
         $validation_fields['customer_id']=['isInteger','Customer Id'];
         $customer_id=$this->payload->customer_id;
         }
         if(isset($this->payload->customer_service_id) && !empty($this->payload->customer_service_id)){
         $validation_fields['customer_service_id']=['isString','Customer service id'];
         $customer_service_id=trim($this->payload->customer_service_id);
         }
         if(isset($this->payload->product_ids) && !empty($this->payload->product_ids)){
         $validation_fields['product_ids']=['isString','Product id list'];
         $product_id_list=trim($this->payload->product_ids);
         }
        
         $this->number_validation_lib->validateInputDataType($this->payload,$validation_fields);
          //Validation end
      
           
              $employeeId = $this->getEmployeeId(); 
              $dealerId = $this->getDealerId();
          
         if($employeeId > 0 && $dealerId > 0)
          {
                    
        $this->load->model(array('WsModel','CustomersModel'));
        
        
        $reason_id=3;
        $arr_getRenewServicesList=array();
        
	   $product_ids = explode(',', $product_id_list);
           /* $is_base_exist = $this->CustomersModel->isBasePackageExists($product_ids);
			$addon_after_base = $this->WsModel->getLovValue('ADDON_AFTER_BASEPACK',$dealerId);
            if(($is_base_exist == 1 && $addon_after_base == 1) || $addon_after_base == 0 ){*/
				/*$service_activation = 2;
				$renewal_from_ezybill_app=1;
				$renewal_from_lco_portal=0;
				$autToken=1234;
				$cf_objj = new CommonFunctions();      
				$smsurl = $cf_objj->checkUrl()."Ajax/WS_stbrenew"; 
				$data = array(
					'customer_id' => urlencode($customer_id),
					'service_activation' => urlencode($service_activation),
					'dealer_id' => $dealer_id,
					'employee_id' => $employeeId,
					'renewal_from_ezybill_app' => urlencode($renewal_from_ezybill_app),
					'renewal_from_lco_portal'=> urlencode($renewal_from_lco_portal),
					'customer_service_id'  => $customer_service_id
				);
				$str_result = $this->WsModel->callCurl($smsurl,$data);
				$arr_result = explode("@",$str_result);
				$result = isset($arr_result[0])?$arr_result[0]:0;
				$str_message = isset($arr_result[1])?$arr_result[1]:0;
				if(isset($result) && $result==1){
					if($str_message!=''){
						$statusCode = 0;
						$statusMessage = $str_message;
					} else {
						$statusCode = 0;
						$statusMessage = 'Renew successfull';
					}
				}else if(isset($result) && $result==2){                
					$statusCode = 1;
					$statusMessage = 'Failed to Renew';
				}else{                
					$statusCode = 1;
					$statusMessage = 'Invalid Arguments';
				}*/
                
                
                
              
            //User Details
            $userDetails = $this->WsModel->getusersDetails($dealerId, $employeeId);
            //Modules
            $this->load->model('AccessModel');
             $modules= $this->AccessModel->get_modules($dealerId);
             $modules_array=array();
             foreach($modules as $module){
            $modules_array[$module->module_name] = $module->module_name;
                  }
            
            //DealerSettings
            $array_dealer_setting=array();
            $this->load->library('LovModel');
               
            $array_dealer_setting = $this->LovModel->setDealerSettings($dealerId);
        
                $is_customer_temp_reason_exist=0;
                    $operation_name = "stb_renew_from_app";
                    $data = array(
                        'customer_id' => $customer_id,
                        'dealer_id' => $dealerId,
                        'employee_id' => $employeeId,
                        'service_activation'=>2,
                        //'authToken' => $authToken,
                        'is_customer_temp_reason_exist'=> $is_customer_temp_reason_exist,
                        'is_unpaid_temp_renew_service'=>1,// if it is 1 and is_customer_temp_reason_exist is 0 to  Service is Renew
                        'operation_name'=>$operation_name
                    );
                   
                    $this->load->library('Temporary_activation_lib');
                    $result = $this->temporary_activation_lib->temporaryActivation($data,$userDetails,$array_dealer_setting,$modules_array);
                    
                
                    if ($result['status'] == 1)$statusCode = 0;else $statusCode=1;
                        
                    $errorCode = $result['errorCode'];
                    $statusMessage = $result['errorMessage'];
                    
		/*	}else{
                $statusCode = 1;
                $statusMessage = 'No base package exist';
            }	*/
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
       
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);
         $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
     }
    }
   
    /**
     * API service:getRenewServicesList
     * @author soujanya 10-7-2023
     * @params {"customer_id:Integer}//
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/
public function getRenewServicesList_post()
    {		
    try{
        
        $statusCode=1;
        $statusMessage = '';

        //validations
        $validation_fields=['customer_id'=>['isInteger','Customer Id']];
        $validation_response_array=  $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }



          //Validation end
        $customer_id=$this->payload->customer_id;
        $this->load->model('CustomersModel');
        $reason_id=3;
        $arr_getRenewServicesList=array();
       
        $employeeId = $this->getEmployeeId(); 
        $dealerId = $this->getDealerId();
      
         if($employeeId > 0 && $dealerId > 0)
          {
                
            //get the renew services list
            $arr_getRenewServicesList = $this->CustomersModel->get_deact_customer_services($customer_id,$reason_id,array(),1,0,1,0,$dealerId);
            //echo $this->db->last_query(); exit;
            if(!empty($arr_getRenewServicesList))
            {
                $statusCode = 0;
                $statusMessage = 'Success';
            }else{
                $statusMessage = 'No Services';
            }
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
      
         $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'getRenewServices' => $arr_getRenewServicesList);
       
         
         $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    }
    
     /**
     * API service:getComplaintsubCategory
     * @author soujanya 10-7-2023
     * @params {"complaintcategory:Integer}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaintSubCategories' => $arr_subcategories)
    **/   
    public function getComplaintsubCategory_post()
    {
        try{
       

        $statusCode=1;
        $statusMessage = '';
        $int_complaintcategory =0;
        //validations
         $validation_fields=array();
          if(isset($this->payload->complaintcategory) && !empty($this->payload->complaintcategory)){
         $validation_fields['complaintcategory']=['isInteger','Complaint Category'];
         $int_complaintcategory=$this->payload->complaintcategory;
         }
         $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }


          //Validation end

        $subcategories = array();
        $arr_subcategories = array();
        $employeeId = $this->getEmployeeId(); 
        $dealerId = $this->getDealerId();
          
         if($employeeId > 0 && $dealerId > 0)
          {
        
           $this->load->model('Simplecomplaints_model');
           $simplecomplaintsModel = new Simplecomplaints_model();
            $subcategories = $simplecomplaintsModel->getSubcategories($dealerId,$int_complaintcategory);
            if(!empty($subcategories))
            {
                $statusCode = 0;
                $statusMessage = 'Success';
                foreach ($subcategories as $subcategoriesData) 
                {
                    $data = array();
                    $data['complaint_category_id'] = isset($subcategoriesData->complaint_category_id)?$subcategoriesData->complaint_category_id:0;
                    $data['complaint_category_name'] = isset($subcategoriesData->category)?$subcategoriesData->category:0;
                    array_push($arr_subcategories, $data);
                }
            }
            elseif ($int_complaintcategory == 0)
            {
                $statusMessage = 'Please Enter Category';
            }
            else
            {
                $statusCode = 1;
                $statusMessage = 'No records found.';
            }
        }
        else
        {
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
        
         $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaintSubCategories' => $arr_subcategories);
     
         $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    }
/**
     * API service:updateCustomerLocation
     * @author soujanya 10-7-2023
     * @params {"latitude:Integer","longitude:Integer","customer_id:Integer"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'complaintSubCategories' => $arr_subcategories)
    **/     
public function updateCustomerLocation_post()
    {
     try{   
    
        $statusCode=1;
        $statusMessage = '';
        $str_latitude='';
        $str_longitude='';
        $customer_id=0;
        //validations
        $validation_fields=array();
          if(isset($this->payload->latitude) && !empty($this->payload->latitude)){
         $validation_fields['latitude']=['isString','Latitude'];
         $str_latitude=$this->payload->latitude;
         }
        if(isset($this->payload->longitude) && !empty($this->payload->longitude)){
         $validation_fields['longitude']=['isString','Longitude'];
         $str_longitude=$this->payload->longitude;
         }
         if(isset($this->payload->customer_id) && !empty($this->payload->customer_id)){
         $validation_fields['customer_id']=['isInteger','Customer Id'];
         $customer_id=$this->payload->customer_id;
         }
         $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
       if(count($validation_response_array) > 0){  
        $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
        $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
        $response = array(  'status_code'=>$statusCode,
                            'status_msg'=>$statusMessage
                        );
        $this->sendResponse($response);
    }
          //Validation end
        $employeeId = $this->getEmployeeId(); 
        $dealerId = $this->getDealerId();
       
         if($employeeId > 0 && $dealerId > 0)
         {
         $this->load->model('WsModel');
	
            $updateLatLong = $this->WsModel->mapCoordinates($customer_id,$str_latitude,$str_longitude);
            //echo $this->db->last_query(); exit;
            if($updateLatLong==1)
            {
                $statusCode = 0;
                $statusMessage = 'customer location updated successfully';
            }else{
                $statusMessage = 'location update failed';
            }
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
  
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);     
         $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    }

 /**
     * API service:getReceiptRanges
     * @author RameshDudala 27-Dec-2021
     * @params {""}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'ReceiptRanges' => $get_receipt_array)
 **/
public function getReceiptRanges_post()
{
  try{
      
    $status_code=1;
    $status_msg = 'FAIL';
    $get_receipt_array=array();

   // $empid=$this->input->post('employee_id')?mysqli_real_escape_string($db,trim($this->input->post('employee_id'))):'0';
    $empid = $this->getEmployeeId(); 
    
    
    if($empid != 0){
        $this->load->model('ReceiptModel');
        $get_receipt = $this->ReceiptModel->getLcoReceiptRangesNew($empid);
        if(!is_array($get_receipt)) {

            $get_receipt_array=explode(',', $get_receipt);
            // sorting receipt in ascending order
            sort($get_receipt_array);
            if(count($get_receipt_array)>0)
            {
                $status_code=0;
                $status_msg='Success';
            } else {
                $status_msg='No Receipt range found.';
            }
        } else {
            $status_msg='No Receipt range found.';
        }
    }
    else{
        $status_msg = 'Invalid Employee id';
    }

        $response =array('status_code' => $status_code,'status_msg' =>$status_msg,'ReceiptRanges' => $get_receipt_array);
         $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    
    }

   /**
     * API service:getLcoEmployeeList
     * @author soujnaya 10-7-2023
     * @params {"employee_id:Integer"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'lcoEmployeelist"=>$arr_lcoEmployeeLis)
    **/   
    public function getLcoEmployeeList_post()
    {
     try{
        $statusCode=1;
        $statusMessage = '';
        $lco_employee_id =0;
  //validations
         $validation_fields=array();
          if(isset($this->payload->employee_id) && !empty($this->payload->employee_id)){
         $validation_fields['employee_id']=['isInteger','LCO Id'];
         $lco_employee_id=$this->payload->employee_id;
         }
         $validation_response_array = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
       if(count($validation_response_array) > 0){  
        $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
        $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
        $response = array(  'status_code'=>$statusCode,
                            'status_msg'=>$statusMessage
                        );
        $this->sendResponse($response);
    }
          //Validation end
        $employeeId = $this->getEmployeeId(); 
        $dealer_id = $this->getDealerId();
        $arr_lcoEmployeeList = array();
        if($employeeId>0 && $dealer_id>0)
        {
          $this->load->model('Simplecomplaints_model');
          $simplecomplaintsModel = new Simplecomplaints_model();
          write_to_file(" ============= getLcoEmployeeList lco_employee_id ========== ".$lco_employee_id);
            $lcoEmployeelist = $simplecomplaintsModel->getLcoEmployeeList($dealer_id,$lco_employee_id);
            write_to_file(" ============= getLcoEmployeeList query ========== ".$this->db->last_query());
            if(!empty($lcoEmployeelist))
            {
                $statusCode = 0;
                $statusMessage = 'Success';
                foreach ($lcoEmployeelist as $lcoData) 
                {
                    $data = array();
                    $data['lco_employee_id'] = isset($lcoData->employee_id)?$lcoData->employee_id:0;
                    $title =    isset($lcoData->parent_code)?$lcoData->parent_code:'';
                    $business_name = isset($lcoData->business_name)?trim($lcoData->business_name):'';
                    $uname = isset($lcoData->name)?trim($lcoData->name):'';
                    $data['lco_employee_name'] = $uname."(".$title.")";
                    array_push($arr_lcoEmployeeList, $data);
                }
            }
            elseif ($lco_employee_id == 0)
            {
                $statusCode = 1;
                $statusMessage = 'Please Enter LCO Id';
            }
            else
            {
                $statusCode = 1;
                $statusMessage = 'No records found.';
            }
        }
        else
        {
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
     
        
        $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,"lcoEmployeelist"=>$arr_lcoEmployeeList);
         $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    }

       /**
     * API service:getComplaintList
     * @author soujanya 10-7-2023
     * @params {""}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'lcoComplaintlist"=>$arr_lcoComplaintList)
    **/   
    public function getComplaintList_post()
    {
 
    try{
        $statusCode=1;
        $statusMessage = '';
        $objscm = new Simplecomplaints_model;
        $service_employee_id = isset($this->payload->serviceemployeeid) ? $this->payload->serviceemployeeid : 0;
        if($service_employee_id < 0){
            $service_employee_id = 0;
            $this->payload->serviceemployeeid=0;
        }
        $users_type = isset($this->payload->login_users_type) ? $this->payload->login_users_type : 'RESELLER';
        $validation_fields=['serviceemployeeid'=>['isInteger','service employee id'],'login_users_type'=>['isString','login users type']];
        $validation_response_array  = $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
         if(count($validation_response_array) > 0){  
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
         $employeeId = $this->getEmployeeId(); 
         $dealer_id = $this->getDealerId();
        
        $arr_lcoComplaintList = array();
        $final_arr_lcoComplaintList = array();
        if($employeeId>0 && $dealer_id>0)
        {
            $this->load->model('Simplecomplaints_model');
            $arr_lcoComplaintList = $objscm->getComplaintsList($dealer_id,$employeeId,$users_type,$service_employee_id);
            log_message('debug',$this->db->last_query());
            //print_r($arr_lcoComplaintList);
            //exit;
            $i = 0;
            foreach ($arr_lcoComplaintList as $k => $value) {
                if(isset($value->status) && $value->status != "CLOSED"){
                    $final_arr_lcoComplaintList[$i] = $value;
                    $i = $i + 1;
                }
            }
            if(!empty($final_arr_lcoComplaintList))
            {
                $statusCode = 0;
                $statusMessage = 'Success';
            }
            else
            {
                $statusCode = 1;
                $statusMessage = 'No records found.';
            }
        }
        else
        {
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
       
        $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,"lcoComplaintlist"=>$final_arr_lcoComplaintList);
               $encry_response = $this->encryption_lib->app_data_encryption($response);
        
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    }

 //function for pairing
         /**
     * API service:stbPairRest
     * @author RameshDudala 28-Dec-2021
     * @params {"serialNumber"=>Integer,"vcNumber"=>Integer}
     * @return array('status_code'=>$statusCode,'error_code'=>$errorCode, 'status_msg'=>$statusMessage)
    **/
  public function stbPairRest_post() {
        try {
            $statusCode = 1;
            $statusMessage = '';
            $errorCode = 'ERR_0000';
            $serialNumber = '';
            $vcNumber = '';
            //validations
            $validation_fields = array();
            if (isset($this->payload->serialNumber) && !empty($this->payload->serialNumber)) {
                $validation_fields['serialNumber'] = ['isString|isRequired', 'Serial Number'];
                $serialNumber = $this->payload->serialNumber;
            }
            if (isset($this->payload->vcNumber) && !empty($this->payload->vcNumber)) {
                $validation_fields['vcNumber'] = ['isString|isRequired', 'VC Number'];
                $vcNumber = $this->payload->vcNumber;
            }

            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload, $validation_fields);
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }
            //Validation end
            $int_stock_id = 0;
            $int_backend_setup_id = 0;
            $str_login_users_type = '';
            $str_login_employee_parent_type = '';
            $int_login_employee_parent_id = 0;
            $str_username = '';
            $str_first_name = '';
            $str_last_name = '';
            $array_dealer_setting = array();
            $obj = new WsModel();
            $cf_objj = new CommonFunctions();

            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();

            if ($employeeId > 0 && $dealerId > 0) {

                $stokDetails = $obj->stockDetails($serialNumber);
                if (!empty($stokDetails)) {
                    $int_stock_id = $stokDetails->stock_id;
                    $int_backend_setup_id = $stokDetails->backend_setup_id;
                }
                $userDetails = $obj->getusersDetails($dealerId, $employeeId);

                if (!empty($userDetails)) {
                    $str_login_users_type = $userDetails->users_type;
                    $str_login_employee_parent_type = $userDetails->employee_parent_type;
                    $int_login_employee_parent_id = $userDetails->employee_parent_id;
                    $str_username = $userDetails->username;
                    $str_first_name = $userDetails->first_name;
                    $str_last_name = $userDetails->last_name;
                }
                $this->load->library('LovModel');
                /*$dealrSettings = $this->LovModel->getDelearSetting($dealerId);
                if (!empty($dealrSettings)) {
                    $array_dealer_setting = (array) $dealrSettings;
                }*/
                $array_dealer_setting = $this->setDealerSetting($this->LovModel->getDelearSetting($dealerId));
                $arr_data = array(
                    'str_serial_number' => $serialNumber,
                    'str_vc_number' => $vcNumber,
                    'int_stock_id' => $int_stock_id,
                    'int_file_data_type' => 3,
                    'int_backend_setup_id' => $int_backend_setup_id,
                    'int_dealer_id' => $dealerId,
                    'str_login_users_type' => $str_login_users_type,
                    'int_login_employee_id' => $employeeId,
                    'str_login_employee_parent_type' => $str_login_employee_parent_type,
                    'int_login_employee_parent_id' => $int_login_employee_parent_id,
                    'operation_name' => 'stb_pair_from_app',
                    'str_act_remarks' => 'Activation of service while pairing STB from app',
                    'array_dealer_setting' => $array_dealer_setting,
                    'double_stb_discount' => 0
                );

                $this->load->library('pairunpair_lib');
                $arr_status = $this->pairunpair_lib->doPair($arr_data);

                if (getStatus($arr_status[STATUS])) {
                    if (isset($arr_status['serial_number']) && isset($arr_status['vc_number'])) {
                        $this->load->model('change_pass_model');
                        $comment = "User Name:$str_username, $str_first_name $str_last_name has did the pairing, " . $arr_status['serial_number'] . " is paired with vc number " . $arr_status['vc_number'];
                        $this->change_pass_model->updateLog($comment, $dealerId, $employeeId);
                    }
                }
                if(1==$arr_status[STATUS])$statusCode=0; else $statusCode=1;
                $errorCode = $arr_status[ERR_CODE];
                $statusMessage = $arr_status[ERR_MSG];
            } else {
                $statusMessage = 'Dealer or Employee does not exist';
            }


            $response = array('status_code' => $statusCode, 'error_code' => $errorCode, 'status_msg' => $statusMessage);
           //print_r($response);exit;
            $encry_response = $this->encryption_lib->app_data_encryption($response);

            $this->response($encry_response, 200);
        } catch (Exception $e) {

            $this->error_res($e, 200);
        }
    }

//function for unpairing
         /**
     * API service:stbUnpairRest
     * @author soujanya 10-7-2023
     * @params {"serialNumber"=>String}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/
  public function stbUnpairRest_post() {
        try {
            $statusCode = 1;
            $errorCode = 'ERR_000';
            $statusMessage = '';
            $serialNumber = '';

            //validations
            $validation_fields = array();
            if (isset($this->payload->serialNumber) && !empty($this->payload->serialNumber)) {
                $validation_fields['serialNumber'] = ['isString|isRequired', 'Serial Number'];
                $serialNumber = $this->payload->serialNumber;
            }
           $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload, $validation_fields);
            // validation count
            if(count($validation_response_array) > 0){
               // validation error
               $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
               $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
               $response = array(  'status_code'=>$statusCode,
                                   'status_msg'=>$statusMessage
                               );
               $this->sendResponse($response);
           }
            //Validation end
            $int_stock_id = 0;
            $int_backend_setup_id = 0;
            $str_login_users_type = '';
            $str_login_employee_parent_type = '';
            $int_login_employee_parent_id = 0;
            $str_username = '';
            $str_first_name = '';
            $str_last_name = '';
            $array_dealer_setting = array();
            $obj = new WsModel();
            $cf_objj = new CommonFunctions();

            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();

            if ($employeeId > 0 && $dealerId > 0) {


                $stokDetails = $obj->stockDetails($serialNumber);
                if (!empty($stokDetails)) {
                    $int_stock_id = $stokDetails->stock_id;
                    $int_backend_setup_id = $stokDetails->backend_setup_id;
                }
                $userDetails = $obj->getusersDetails($dealerId, $employeeId);

                if (!empty($userDetails)) {
                    $str_login_users_type = $userDetails->users_type;
                    $str_login_employee_parent_type = $userDetails->employee_parent_type;
                    $int_login_employee_parent_id = $userDetails->employee_parent_id;
                    $str_username = $userDetails->username;
                    $str_first_name = $userDetails->first_name;
                    $str_last_name = $userDetails->last_name;
                }
                $this->load->library('LovModel');
                /*$dealrSettings = $this->LovModel->getDelearSetting($dealerId);
                if (!empty($dealrSettings)) {
                    $array_dealer_setting = (array) $dealrSettings;
                }*/
                $array_dealer_setting = $this->setDealerSetting($this->LovModel->getDelearSetting($dealerId));
                $arr_data = array(
                    'int_stock_id' => $int_stock_id,
                    'int_file_data_type' => 3,
                    'int_backend_setup_id' => $int_backend_setup_id,
                    'operation_name' => 'stb_unpair_from_app',
                    'str_deact_remarks' => 'Deactivation of service while unpairing from app',
                    'int_dealer_id' => $dealerId,
                    'str_login_users_type' => $str_login_users_type,
                    'int_login_employee_id' => $employeeId,
                    'str_login_employee_parent_type' => $str_login_employee_parent_type,
                    'int_login_employee_parent_id' => $int_login_employee_parent_id,
                    'array_dealer_setting' => $array_dealer_setting
                );

                $this->load->library('pairunpair_lib');
                $arr_status = $this->pairunpair_lib->doUnpair($arr_data);
                //print_r($arr_status);
                if (getStatus($arr_status[STATUS])) {
                    if (isset($arr_status['serial_number']) && isset($arr_status['vc_number'])) {
                        $this->load->model('change_pass_model');
                        $comment = "User Name:$str_username, $str_first_name $str_last_name has unpaired, " . $arr_status['serial_number'] . " is unpaired with vc number " . $arr_status['vc_number'];
                        $this->change_pass_model->updateLog($comment, $dealerId, $employeeId);
                    }
                }
                if(1==$arr_status[STATUS])$statusCode=0; else $statusCode=1;
                $errorCode = $arr_status[ERR_CODE];
                $statusMessage = $arr_status[ERR_MSG];
            } else {
                $statusMessage = 'Dealer or Employee does not exist';
            }


            $response = array('status_code' => $statusCode, 'error_code' => $errorCode, 'status_msg' => $statusMessage);
            //print_r($response);exit;

            $encry_response = $this->encryption_lib->app_data_encryption($response);

            $this->response($encry_response, 200);
        } catch (Exception $e) {

            $this->error_res($e, 200);
        }
    }

    /**
     * API service:deactivateBoxRest
     * @author soujanya 10-7-2023
     * @params {"serialNumber":String,"vcNumber":String,"boxNumber":String,"macAddress":String,"stockId":Integer,"deviceId":Integer,"backEndSetupId":Integer,"reasonId":Integer,"remarks":String,"from_mobileapp":integer}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/
    public function deactivateBoxRest_post()
    {
        try
        {
            $statusCode=1;
            $statusMessage = '';
            $is_temp_deactivated=array();
            $serialNumber = '';
    	    $vcNumber = '';
    	    $boxNumber ='';
            $macAddress = '';
    	    $stockId = 0;
    	    $deviceId = 0;
    	    $backEndSetupId = 0;
    	    $reasonId = 0;
    	    $remarks = 0;
            $from_mobileapp = 0;
            //validations
            $validation_fields=array();
            
            $validation_fields['customerId']=['isInteger|isRequired','Customer Id'];
            $customerId=isset($this->payload->customerId)?$this->payload->customerId:'';

            $validation_fields['serialNumber']=['isString|isRequired','Serial Number'];
            $serialNumber=isset($this->payload->serialNumber)?$this->payload->serialNumber:'';

            $validation_fields['vcNumber']=['isString|isRequired','VC Number'];
            $vcNumber=isset($this->payload->vcNumber)?$this->payload->vcNumber:'';

            $validation_fields['boxNumber']=['isString|isRequired','Box Number'];
            $boxNumber=isset($this->payload->boxNumber)?$this->payload->boxNumber:'';

            $validation_fields['macAddress']=['isString|isRequired','MAC Address'];
            $macAddress=isset($this->payload->macAddress)?$this->payload->macAddress:'';

            $validation_fields['stockId']=['isInteger|isRequired','Stock Id'];
            $stockId=isset($this->payload->stockId)?$this->payload->stockId:0;   

            $validation_fields['deviceId']=['isInteger','Device Id'];
            $deviceId=isset($this->payload->deviceId)?$this->payload->deviceId:0;  

            $validation_fields['backEndSetupId']=['isInteger|isRequired','Backend Setup Id'];
            $backEndSetupId=isset($this->payload->backEndSetupId)?$this->payload->backEndSetupId:0;

            $validation_fields['reasonId']=['isInteger|isRequired','Reason Id'];
            $reasonId=isset($this->payload->reasonId)?$this->payload->reasonId:0; 

            $validation_fields['remarks']=['isString|isRequired','Remarks'];
            $remarks=isset($this->payload->remarks)?$this->payload->remarks:'';  

            $validation_fields['from_mobileapp']=['isInteger','From Mobile App'];
            $from_mobileapp=isset($this->payload->from_mobileapp)?$this->payload->from_mobileapp:0;

            $validation_fields['resellerId']=['isInteger|isRequired','Reseller Id'];
            $int_reseller_id=isset($this->payload->resellerId)?$this->payload->resellerId:0;

            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                //   validation
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }

            $data = array();
          //Validation end
			$obj = new WsModel();
            $cf_objj = new CommonFunctions();
			$cust = new CustomersModel();
            $employeeId = $this->getEmployeeId(); 
            $dealerId = $this->getDealerId();
            $this->load->model('Process_Model');
            $is_temp_deactivated=0;
			//Get the dealer_id and employee_id from auth token
           
                if($employeeId != 0 && $dealerId != 0)
                {			             
				    if($from_mobileapp==1)
                    {
                        $int_operation_id= $this->Process_Model->getoperation_id('deactivation_stb_from_app',$dealerId);
                    }
                    else
                    {
                        $int_operation_id= $this->Process_Model->getoperation_id('deactivation_stb_from_thirparty_api',$dealerId);
                        $remarks='Box Deactivation from Third Party API';
                    }
                    $data['operation_id'] = $int_operation_id;
                    $arr_backend_setups = array();
                    $arr_stock_id = array();
                    if($backEndSetupId !='')
                    {
                        $arr_backend_setups = explode(",",$backEndSetupId);
                    }
                    if($stockId !='')
                    {
                        $arr_stock_id = explode(",",$stockId);
                    }
                    $arr_deactivate_box_details['customer_id'] = $customerId;
                    $arr_deactivate_box_details['plugin_id'] = 4;
                    $arr_deactivate_box_details['arr_stock_id'] = $arr_stock_id;
                    $arr_deactivate_box_details['arr_backend_setups'] = $arr_backend_setups;
                    $arr_deactivate_box_details['delaer_id'] = $dealerId;
                    $arr_deactivate_box_details['reseller_id'] = $int_reseller_id;
                    $arr_deactivate_box_details['deact_reason_id'] = $reasonId;
                    $arr_deactivate_box_details['str_deact_remarks'] = $remarks;
                    $this->load->library(array('Prepare_deactivation_post_data_lib','Workflow_lib'));	
                    
                    $this->setSessionData($employeeId, $dealerId);
                    $userType = isset($_SESSION['user_data']->users_type) ? $_SESSION['user_data']->users_type : '';
                    $employeeId = isset($_SESSION['user_data']->employee_id) ? $_SESSION['user_data']->employee_id : 0;
                    $str_login_employee_parent_type = isset($_SESSION['user_data']->employee_parent_type) ? $_SESSION['user_data']->employee_parent_type : '';
                    $int_login_employee_parent_id = isset($_SESSION['user_data']->employee_parent_id) ? $_SESSION['user_data']->employee_parent_id : 0;
                    $array_dealer_setting = isset($_SESSION['dealer_setting']) ? ( array ) $_SESSION['dealer_setting'] : array();
                    write_to_file(" ============= array_dealer_setting ============ ".json_encode($array_dealer_setting));
                    $extra_params['users_type'] = $userType;
                    $extra_params['employee_id'] = $employeeId;
                    $extra_params['employee_parent_type'] = $str_login_employee_parent_type;
                    $extra_params['employee_parent_id'] = $int_login_employee_parent_id;
                    $extra_params['array_dealer_setting'] = $array_dealer_setting;
                    $data_for_operation = $this->prepare_deactivation_post_data_lib->prepareGlobalDeactivationPostData($arr_deactivate_box_details,$extra_params);
                    $activity_id = 15; // activity name = bulk_deactivation
                    log_message("debug","=============arr_deact_cas_productIds===================".json_encode($data_for_operation));
                    //$int_operation_id = isset($data_for_operation['extra_parameters']['int_operation_id'])?$data_for_operation['extra_parameters']['int_operation_id']:0;
                    $data_for_operation['extra_parameters']['int_operation_id'] = $int_operation_id;
                    log_message("debug","=============LCO Respt API Deactivation int_operation_id===================".$int_operation_id);
                    //print_r($data_for_operation);exit;
                    $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $data_for_operation);
                    log_message("debug","=============data_for_operation=====RES==============".json_encode($data_for_operation));
                    if(isset($data_for_operation[STATUS]) && $data_for_operation[STATUS]==1)
                    {
                       $statusMessage =  'Box De-Activated Successfully.';
                        $statusCode = 0;  
                    } 
                    else
                    {
                        
                        $statusCode = 1;
                        //$errorCode = isset($data_for_operation['error_code'])?$data_for_operation['error_code']:"";
                        //$statusMessage = getErrorMessages($errorCode);
                        $statusMessage = isset($data_for_operation['error_message'])?$data_for_operation['error_message']:"";
                    }     
                }
                else
                {

                        $statusMessage = 'Dealer or Employee does not exist';				
                }
            
         $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'is_temp_deactivated'=>$is_temp_deactivated);
         $this->sendResponse($response);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }                 
    }	
    public function setSessionData($int_reseller_id, $int_dealer_id,$int_check_suspended_flag=0)
    {
        if($int_dealer_id>0 && $int_reseller_id>0)
        {
            $obj_commonfunctions = new commonfunctions();
            //Set $_SESSION['user_data'] and $_SESSION['user_data']->employee
            $obj_commonfunctions->setUserData($int_reseller_id, $int_dealer_id, $flag = 0, $int_check_suspended_flag);
            //Set $_SESSION['access'] and $_SESSION['modules']
            $obj_commonfunctions->setUserAccess();
            //Set $_SESSION['dealer_setting']
            $obj_commonfunctions->setDealerSettings();
            //SET CAS Access
            $obj_commonfunctions->setCasAccess();
        }
    }            
//function to reactivate box

 /**
     * API service:reactivateBoxRest
     * @author soujanya 10-7-2023
     * @params {"stockId":Integer,"serialNumber":String,"boxNumber":String,"macAddress":String,"deviceId":Integer,"backEndSetupId":Integer,"reinitialize":Integer}
     * @return array('status_code'=>$statusCode,'error_code'=>$errorCode,'status_msg'=>$statusMessage)
    **/
   public function reactivateBoxRest_post()
	{

	 try{
            $statusCode=1;
            $errorCode='';
            $statusMessage = '';
            $is_temp_deactivated=array();
            
            $serialNumber = '';
	    $boxNumber ='';
            $macAddress = '';
	    $stockId = 0;
	    $deviceId = 0;
	    $backEndSetupId = 0;
	    $reinitialize = 0;
            $getCustmerIdfindBy='';
 
            //validations
            $validation_fields=array();
     
           
           
            if(isset($this->payload->serialNumber) && !empty($this->payload->serialNumber)){
            $validation_fields['serialNumber']=['isString|isRequired','Serial Number'];
            $serialNumber=trim($this->payload->serialNumber);
            }
    
            if(isset($this->payload->boxNumber) && !empty($this->payload->boxNumber)){
            $validation_fields['boxNumber']=['isString|isRequired','Box Number'];
            $boxNumber=trim($this->payload->boxNumber);
            $getCustmerIdfindBy=$boxNumber;
            }
            if(isset($this->payload->macAddress) && !empty($this->payload->macAddress)){
            $validation_fields['macAddress']=['isString|isRequired','MAC Address'];
            $macAddress=trim($this->payload->macAddress);
            }
           
            if(isset($this->payload->deviceId) && !empty($this->payload->deviceId)){
            $validation_fields['deviceId']=['isInteger|isRequired','Device Id'];
            $deviceId=$this->payload->deviceId;
             $getCustmerIdfindBy=$deviceId;
            }
            if(isset($this->payload->backEndSetupId) && !empty($this->payload->backEndSetupId)){
            $validation_fields['backEndSetupId']=['isInteger|isRequired','Backend Setup Id'];
            $backEndSetupId=$this->payload->backEndSetupId;
            }
            if(isset($this->payload->reinitialize) && !empty($this->payload->reinitialize)){
            $validation_fields['reinitialize']=['isInteger|isRequired','Reason Id'];
            $reinitialize=$this->payload->reinitialize;
            }
            $validation_fields['stockId']=['isInteger|isRequired','Stock Id'];
           

            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        //    print_r($validation_response_array);exit;
            if(count($validation_response_array) > 0){
                // validation error

                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }

          //Validation end
            $stockId=$this->payload->stockId;
             
            
              	$obj = new WsModel();
		$das_obj = new DasModel();
		//$inventory = new Inventorymodel();
		$employeeId = $this->getEmployeeId(); 
                $dealerId = $this->getDealerId();
                                
          
		if($employeeId != 0 && $dealerId != 0)
		{
			if($stockId>0 || $serialNumber!=''){
				$stock_details = $das_obj->getStockDetails($stockId);
                               
				if(!empty($stock_details)){
					$boxNumber = $stock_details->vc_number;
					$macAddress = $stock_details->mac_address;
				}
			    
				/*$reseller_id = $inventory->validateStock($serialNumber,$dealerId);
				if($reseller_id>0){     // condition removed because delaer cannot reactivate box && $reseller_id==$employeeId
					$res = $obj->activateEntireBox($serialNumber,$boxNumber,$backEndSetupId,$macAddress,$deviceId,'R',$stockId,$dealerId,$employeeId,$pname='',$product_id=0, $product_names='',$reason_id=0,$remarks='',$reinitialize);	
					if($res)
					{
						$statusMessage = 'Succesfully reactivated';
					}
					else
					{
                                               $statusMessage = 'Failed to reactivate';
					}
				}else{
					$statusMessage = "STB doesn't exist in LCO location";
				}*/
                    $this->load->model('CustomersModel');      
                    $int_customer_id =$this->CustomersModel->getCustomerId($dealerId,$getCustmerIdfindBy);
                    $int_plugin_id = 4;
                    $int_dealer_id = $dealerId;
                    $int_login_employee_id  = $employeeId;
                    $array_dealer_setting=array();
                    if (!($int_customer_id > 0 && $int_plugin_id > 0)) {
                        $errorCode = 'ERR_RA_0001';
                        $statusMessage = getErrorMessages($errorCode);
                        log_message('custom', $statusMessage);
                        throw new Exception($statusMessage);
                    }
                    $str_sel_values = '';
                    if (4 == $int_plugin_id) { // CAS
                        $str_sel_values = $stockId;
                    } elseif (3 == $int_plugin_id) { //OTT
                        $str_sel_values = $backEndSetupId;
                    } elseif (1 == $int_plugin_id) { // ISP
                        $str_sel_values = $backEndSetupId;
                    }

                    $this->load->model('Process_Model');
                    $operation_name = 'globalsearch_reactivation';
                    $int_operation_id = $this->Process_Model->getoperation_id($operation_name, $int_dealer_id);
              
                     if(!($int_customer_id>0 && $int_plugin_id>0 && $int_operation_id>0)){
                $data_for_operation=array();
                   }
            $this->load->library('Prepare_activation_postdata_lib');
            $this->load->library('LovModel');
                $array_dealer_setting = $this->LovModel->setDealerSettings($int_dealer_id);

                $int_bundle_common_pipe_support = isset($array_dealer_setting->BUNDLE_COMMON_PIPE_SUPPORT)?$array_dealer_setting->BUNDLE_COMMON_PIPE_SUPPORT:0;
                
            $array_dealer_setting = ['ADDON_AFTER_BASEPACK'=>$array_dealer_setting->ADDON_AFTER_BASEPACK,'BUNDLE_COMMON_PIPE_SUPPORT'=>$int_bundle_common_pipe_support];
            $extra_params['array_dealer_setting'] = $array_dealer_setting;
          
            $data_for_operation = $this->prepare_activation_postdata_lib->prepareDataForReactivation($int_dealer_id, $int_login_employee_id, $int_customer_id, $int_plugin_id, $str_sel_values, $int_operation_id, $extra_params);
        

                    if (count($data_for_operation) > 0 && $int_operation_id > 0) {
                        $this->load->library('Workflow_lib');
                        $activity_id = 12; // activity name = reactivation_of_service
                        $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $data_for_operation);

                        if( 1==$data_for_operation[STATUS]) $statusCode=0; else $statusCode=1;
                        $errorCode = $data_for_operation[ERR_CODE];
                        $statusMessage = $data_for_operation[ERR_MSG];
                    } else {
                        $statusCode = 1;
                        $errorCode = 'ERR_RA_0001';
                        $statusMessage = getErrorMessages($errorCode);
                        log_message('CUSTOM', $statusMessage);
                    }
                }
		}
		else
		{
                    $statusMessage = 'Dealer or Employee does not exist';
			
		}	
               
            $response =array('status_code'=>$statusCode,'error_code'=>$errorCode, 'status_msg'=>$statusMessage);
            $encry_response = $this->encryption_lib->app_data_encryption($response);
        
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       } 
    }	
    
    

/**
     * API service:temporaryActivationRest
     * @author RameshDudala 30-Dec-2021,Workflow Integration on 11-Jan-2022 updated by soujanya on 10-7-2023
     * @params {"customerId":Integer}
     * @return array('status_code'=>$statusCode,'errorCode'=>$errorCode, 'status_msg'=>$statusMessage)
    **/    
 //function to activate Temporary deactivated STB 
 public function temporaryActivationRest_post() {

        try {
             $statusCode = 1;
             $errorCode='';
            $statusMessage = '';
            $errorCode = '';
            //validations
            $validation_fields = array();

            $customerId = isset($this->payload->customerId) ? $this->payload->customerId : 0;
            $stockId = isset($this->payload->stockId) ? $this->payload->stockId : 0;
 
            $validation_fields = ['customerId' => ['isInteger|isRequired', 'Customer Id'],'stockId' => ['isInteger|isRequired', 'Stock Id']];


            $validation_response_array   =   $this->number_validation_lib->validateInputDataType_updated($this->payload, $validation_fields);
            //Validation end
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }

            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();

            if ($employeeId > 0 && $dealerId > 0) {
                
            $this->load->model('WsModel');
            //User Details
            $userDetails = $this->WsModel->getusersDetails($dealerId, $employeeId);
            //Modules
            $this->load->model('AccessModel');
             $modules= $this->AccessModel->get_modules($dealerId);
             $modules_array=array();
             foreach($modules as $module){
            $modules_array[$module->module_name] = $module->module_name;
                  }
            
            //DealerSettings
            $array_dealer_setting=array();
            $this->load->library('LovModel');
               
            $array_dealer_setting = $this->LovModel->setDealerSettings($dealerId);
        
                $is_customer_temp_reason_exist=1;
                    $operation_name = "temporary_activation_from_app";
                    $data = array(
                        'customer_id' => $customerId,
                        'dealer_id' => $dealerId,
                        'employee_id' => $employeeId,
                        //'authToken' => $authToken,
                        'is_customer_temp_reason_exist'=> $is_customer_temp_reason_exist,
                        'operation_name'=>$operation_name
                    );
                   
                    $this->load->library('Temporary_activation_lib');
                    $result = $this->temporary_activation_lib->temporaryActivation($data,$userDetails,$array_dealer_setting,$modules_array);
                    
                
                    if ($result['status'] == 1)$statusCode = 0;else $statusCode=1;
                        
                    $errorCode = $result['errorCode'];
                    $statusMessage = $result['errorMessage'];
                
            } else {
                $statusMessage = 'Dealer or Employee does not exist';
            }


            $response = array('status_code' => $statusCode, 'error_code' => $errorCode, 'status_msg' => $statusMessage);
            $encry_response = $this->encryption_lib->app_data_encryption($response);

            $this->response($encry_response, 200);
        } catch (Exception $e) {

            $this->error_res($e, 200);
        }
    }

    /**
     * API service:deactivateServiceRest
     * @author RameshDudala 30-Dec-2021  updated by soujanya on 10-7-2023
     * @params {"digi_key:Integer","bill_dealer_id:Integer","customerId:Integer","serviceId:Integer","reasonId:Integer","remarks:String","check_validation:Integer","fromCustomerPortal:Integer","deactservice_customer_portal:Integer","fromMobileApp:Integer","callFromDigi:Integer"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/    
   public function deactivateServiceRest_post()
	{
        try
        {
            $statusCode=1;
            $statusMessage = '';
            //validations
//            $digi_key='';
//            $bill_dealer_id=0;
//            $customerId=0;
//            $serviceId=0;
//            $reasonId=0;
//            $remarks='';
//            $check_validation=0;
//            $fromCustomerPortal=0;
//            $deactservice_customer_portal=0;
//            $fromMobileApp=0;
//            $callFromDigi=0;
            $validation_fields=array();
            
            $validation_fields['digi_config_value']=['isInteger','DIGI conifg value'];
            $digi_key=isset($this->payload->digi_config_value)?trim($this->payload->digi_config_value):0;
            $validation_fields['bill_dealer_id']=['isInteger','Bill Dealr Id'];
            $bill_dealer_id=isset($this->payload->bill_dealer_id)?trim($this->payload->bill_dealer_id):0;
            $validation_fields['customerId']=['isInteger|isRequired','Customer Id'];
            $customerId=isset($this->payload->customerId)?trim($this->payload->customerId):0;
            $validation_fields['serviceId']=['isString','Service Id'];
            $serviceId=isset($this->payload->serviceId)?trim($this->payload->serviceId):0;
            $validation_fields['reasonId']=['isInteger','Reason Id'];
            $reasonId=isset($this->payload->reasonId)?trim($this->payload->reasonId):0;
            $validation_fields['remarks']=['isString','Remarks'];
            $remarks=isset($this->payload->remarks)?trim($this->payload->remarks):'';
            $validation_fields['check_validation']=['isInteger','Check Validation'];
            $check_validation=isset($this->payload->check_validation)?trim($this->payload->check_validation):0;
            //below code added for selfcare deactivations
            $validation_fields['fromCustomerPortal']=['isInteger','From Customer Portal'];
            $fromCustomerPortal=isset($this->payload->fromCustomerPortal)?trim($this->payload->fromCustomerPortal):0;//newly added - customer portal
            //below code added for selfcare deactivation packages separately 
            $validation_fields['deactservice_customer_portal']=['isInteger','Deactivateservice of customer portal'];
            $deactservice_customer_portal=isset($this->payload->deactservice_customer_portal)?trim($this->payload->deactservice_customer_portal):0;//newly added - customer portal
            $validation_fields['fromMobileApp']=['isInteger','From mobile app'];
            $fromMobileApp=isset($this->payload->fromMobileApp)?trim($this->payload->fromMobileApp):0;//newly added - customer portal
            //digi remarks
            $validation_fields['callFromDigi']=['isInteger','Call from DIGI'];
            $callFromDigi=isset($this->payload->callFromDigi)?trim($this->payload->callFromDigi):0;//newly added 
            $validation_fields['stockId']=['isInteger|isRequired','Stock Id'];
            $int_stock_id=isset($this->payload->stockId)?trim($this->payload->stockId):0;
            $validation_fields['resellerId']=['isInteger|isRequired','Reseller Id'];
            $int_reseller_id=isset($this->payload->resellerId)?trim($this->payload->resellerId):0;
            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
             // validation count
             if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }
           //Validation end
            $this->load->model('process_model');   
            $this->load->library(array('App_service_deactivation_post_data_preparation_lib','Workflow_lib'));
		    $obj = new wsModel();
		    $cf_objj = new CommonFunctions();
		    //digi_key added for validating correct server from where BILL is getting accessed 
		    $unpaid_customer = 0;		
    		$employeeId = $this->getEmployeeId(); 
            $dealerId = $this->getDealerId();      
           
            if($employeeId != 0 && $dealerId != 0)
            {		
                $online_customer = $obj->get_customer_online($customerId,$dealerId);
                if($fromCustomerPortal==1 && $online_customer==1 && $deactservice_customer_portal == 0){
                        $statusCode = 1;
                        $statusMessage = 'Services cannot be deactivated for online customer.';
                        return (array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage));
                }
                $operation_name = '';
                if($fromCustomerPortal == 1)
                {
                   //$operation_id= $this->process_model->getoperation_id('deactiveservice_from_selfcare',$dealerId);	
                   $operation_name = 'deactiveservice_from_selfcare';
                }
                else if($fromMobileApp==1)
                {
                    //$operation_id= $this->process_model->getoperation_id('deactiveservice_from_app',$dealerId);	
                    $operation_name = 'deactiveservice_from_app';
                }
                else
                {
                    //$operation_id = $this->process_model->getoperation_id('deactivation_stb_from_thirparty_api',$dealerId);
                    $operation_name = 'deactivation_stb_from_thirparty_api';
                    $remarks=$remarks.'Box Deactivation from Third Party API';
                }	
    			$arr_deactivate_box_details = array();
                $arr_deactivate_box_details['customer_id'] = $customerId;
                $arr_deactivate_box_details['stock_id'] = $int_stock_id;
                $arr_deactivate_box_details['customer_service_id'] = $serviceId;
                $arr_deactivate_box_details['dealer_id'] = $dealerId;
                $arr_deactivate_box_details['reseller_id'] = $int_reseller_id;
                $arr_deactivate_box_details['login_employee_id'] = $employeeId;
                $arr_deactivate_box_details['reasonId'] = $reasonId;
                $arr_deactivate_box_details['remarks'] = $remarks;
                $arr_deactivate_box_details['str_operation_name'] = $operation_name;  
                //$this->setSessionData($employeeId, $dealerId);    
                //$array_dealer_setting = isset($_SESSION['dealer_setting']) ? ( array ) $_SESSION['dealer_setting'] : array();
                //write_to_file(" ============= array_dealer_setting ============ ".json_encode($array_dealer_setting));
                $arr_deact_cas_productIds = $this->app_service_deactivation_post_data_preparation_lib->prepareDeactivationPostData($arr_deactivate_box_details);
                $activity_id = 15; // activity name = bulk_deactivation
                log_message("debug","=============arr_deact_cas_productIds===================".json_encode($arr_deact_cas_productIds));
                $int_operation_id = isset($arr_deact_cas_productIds['extra_parameters']['int_operation_id'])?$arr_deact_cas_productIds['extra_parameters']['int_operation_id']:0;
                log_message("debug","=============LCO Respt API Deactivation int_operation_id===================".$int_operation_id);
                $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $arr_deact_cas_productIds);
                log_message("debug","=============arr_deact_cas_productIds=====RES==============".json_encode($arr_deact_cas_productIds));
                if(isset($arr_deact_cas_productIds[STATUS]) && $arr_deact_cas_productIds[STATUS]==1)
                {
                   $statusMessage =  'Service De-Activated Successfully.';
                    $statusCode = 0;  
                } 
                else
                {
                   $statusMessage = $arr_deact_cas_productIds[ERR_MSG];
                   $statusCode = 1;
                }      				
    		  }
		     else
		     {
			    $statusMessage = 'Dealer or Employee does not exist.';
		     }
            
           $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);
           $this->sendResponse($response);
        } catch(Exception $e)
        {
                    
            $this->error_res($e, 200);
        }        
                
    }	
  
      /**
     * API service:activateServiceRes
     * @author RameshDudala 30-Dec-2021 updated by soujanay on 10-07-2023
     * @params {"customerId: Integer","productId: Integer","customerDeviceId: Integer","dateType: Integer","pricingStructureType: String","validityDays: Integer","quantity: Integer","stockId: Integer","packageEndDate: String","rtype: String","fromCustomerPortal: Integer","customerpayment_id: Integer","paid_at_mso: Integer","fromMobileApp: Integer"}
       * Newly added $this->payload->resellerId
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/  
    public function activateServiceRest_post()
	{
        try
        {	
                
	
            $statusCode = 1;
            $statusMessage = 'service adding failed';
            //validations
            
        
//            $customerDeviceId=0;
//            $dateType=0;
//            $pricingStructureType='';
//            $validityDays=0;
//            $quantity=0;
//            $stockId=0;
//            $packageEndDate='';
//            $rtype='';
//            $fromCustomerPortal=0;
//            $customerpayment_id=0;
//            $paid_at_mso=0;
//            $fromMobileApp=0;
         
            $validation_fields=array();
            $validation_fields['customerId']=['isString|isRequired','Customer Id'];
            $customerId=isset($this->payload->customerId)?trim($this->payload->customerId):0;
            $validation_fields['productId']=['isString|isRequired','Prodcut Id'];
            $productId=isset($this->payload->productId)?trim($this->payload->productId):0;
            /*if(isset($this->payload->customerDeviceId) && !empty($this->payload->customerDeviceId)){
            $validation_fields['customerDeviceId']=['isInteger','Customer Device Id'];
            $customerDeviceId=trim($this->payload->customerDeviceId);
            }
            if(isset($this->payload->dateType) && !empty($this->payload->dateType)){
            $validation_fields['dateType']=['isInteger','Date Type'];
            $dateType=trim($this->payload->dateType);
            }
            if(isset($this->payload->pricingStructureType) && !empty($this->payload->pricingStructureType)){
            $validation_fields['pricingStructureType']=['isString','Pricing structure Type'];
            $pricingStructureType=trim($this->payload->pricingStructureType);
            }
            if(isset($this->payload->validityDays) && !empty($this->payload->validityDays)){
            $validation_fields['validityDays']=['isInteger','Validity Days'];
            $validityDays=trim($this->payload->validityDays);
            }
            if(isset($this->payload->quantity) && !empty($this->payload->quantity)){
            $validation_fields['quantity']=['isInteger','Quantity'];
            $quantity=trim($this->payload->quantity);
            }
            if(isset($this->payload->packageEndDate) && !empty($this->payload->packageEndDate)){
            $validation_fields['packageEndDate']=['isString','Package end date'];
            $packageEndDate=trim($this->payload->packageEndDate);
            }*/
            $validation_fields['stockId']=['isString|isRequired','Stock Id'];
            $stockId=isset($this->payload->stockId)?trim($this->payload->stockId):0;
//            $validation_fields['rtype']=['isString','rtype'];
//            $rtype=isset($this->payload->rtype)?trim($this->payload->rtype):0;
            //newly added - customer portal
            $validation_fields['fromCustomerPortal']=['isString','From Customer Portal'];
            $fromCustomerPortal=isset($this->payload->fromCustomerPortal)?trim($this->payload->fromCustomerPortal):0;
//            $validation_fields['customerpayment_id']=['isString','Customer Payment Id'];
//            $customerpayment_id=isset($this->payload->customerpayment_id)?trim($this->payload->customerpayment_id):0;
//            $validation_fields['paid_at_mso']=['isString','Paid at MSO'];
//            $paid_at_mso=isset($this->payload->paid_at_mso)?trim($this->payload->paid_at_mso):0;
//            $validation_fields['fromMobileApp']=['isString','From mobile app'];
//            $fromMobileApp=isset($this->payload->fromMobileApp)?trim($this->payload->fromMobileApp):0;  
            $validation_fields['resellerId']=['isString|isRequired','Reseller Id'];
            $int_reseller_id=isset($this->payload->resellerId)?trim($this->payload->resellerId):0;          
            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }
           //Validation end

           $action_done_from = 1;
           if($fromCustomerPortal == 1){
        	$action_done_from = 2;
           }	
            $employeeId = $this->getEmployeeId(); 
            $dealerId = $this->getDealerId();        
            $errorList = array('2'=>'Failed to activate the service',
    			'3'=>'Alacarte package or channel already exist',
    			'4'=>'A base package already exist',
    			'5'=>'Invalid box number',
    			'9'=>'You dont have sufficient privileges to activate');
            
                if($employeeId != 0 && $dealerId != 0)
                {	
                    $obj = new wsModel();
                    $cf_objj = new CommonFunctions();
                    $arr_activate_box_details = array();
                    $arr_activate_box_details['customer_id'] = $customerId;
                    $arr_activate_box_details['stock_id'] = $stockId;
                    $arr_activate_box_details['product_id'] = $productId;
                    $arr_activate_box_details['dealer_id'] = $dealerId;
                    $arr_activate_box_details['reseller_id'] = $int_reseller_id;
                    $arr_activate_box_details['login_employee_id'] = $employeeId;
                    $this->load->library(array('App_service_activation_post_data_preparation_lib','Workflow_lib'));
                    $arr_act_cas_productIds = $this->app_service_activation_post_data_preparation_lib->prepareActivationPostData($arr_activate_box_details);
                    $int_operation_id = isset($arr_act_cas_productIds['extra_parameters']['int_operation_id'])?$arr_act_cas_productIds['extra_parameters']['int_operation_id']:0;
                    //print_r($arr_act_cas_productIds);exit;
                    $activity_id = 3; // activity name = Service Activation
                    $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $arr_act_cas_productIds);
                    //print_r($arr_act_cas_productIds);exit;
                    if(getStatus($arr_act_cas_productIds[STATUS]))
                    {                            
                        $statusMessage =  'Service activated Successfully.';
                        $statusCode = 0;
                    } 
                    else
                    {
                       $statusMessage = $arr_act_cas_productIds[ERR_MSG];
                       $statusCode = 1;
                    }      
                }
                else
                {
                        $statusMessage = 'Dealer or Employee does not exist.';
                }
            
            $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);
            $this->sendResponse($response);
        } 
        catch(Exception $e)
        {            
            $this->error_res($e, 200);
        }                 
    }
        
    /**
     * API service:editCustomerRest
     * @author RameshDudala 30-Dec-2021 updated by soujanya 0n 10-7-2023
     * @params {""customerId:Integer","customerTypeId:Integer","caf_no:String","businessName:String","firstName:String","lastName:String","idType:String","idNumber:String","fatherName:String","gender:String","group_aasign:String","discount:String","country:String","state:String","district:String","mandal:Integer","city:String","mobile:String","old_mobile:String","phoneNumber:String","email:String","pinCode:String","address:String","address2:String","address3:String","remarks:String","installationAddress:String","dateOfBirth:String","dateOfAnniversary:String","billType:String","ipAddress:String","pricingStructureType:String","validityDays:String","accountNumber:String","latitude=.0","longitude=.0","username:String","password:String","change_addrs:String","customer_verification:String","idProofImg:String","customerImg:String","customerapplicationformImg:String","baid:String","installation_address:String","customer_sla_id:Integer"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/  
    public function editCustomerRest_post() 
    {

        
        try 
        {
            /*//validations
            $customerId = -1;
            $customerTypeId = 0;
            $caf_no = '';
            $businessName = '';
            $firstName = '';
            $lastName = '';
            $idType = '';
            $idNumber = '';
            $fatherName = '';
            $gender = '';
            $group_aasign = '';
            $discount = '';
            $country = '';
            $state = '';
            $district = '';
            $mandal = 0;
            $city = '';
            $mobile = '';
            $old_mobile = '';
            $phoneNumber = '';
            $email = '';
            $pinCode = '';
            $address = '';
            $address2 = '';
            $address3 = '';
            $remarks = '';
            $installationAddress = '';
            $dateOfBirth = '';
            $d = 0;
            $m = 0;
            $y = 0;
            $dateOfAnniversary = '';
            $ad = 0;
            $am = 0;
            $ay = 0;
            $billType = '';
            $ipAddress = '';
            $pricingStructureType = '';
            $validityDays = '';
            $accountNumber = '';
            $latitude = '';
            $longitude = '';
            $username = '';
            $password = '';
            $change_addrs = '';
            $customer_verification = '';
            $idProofImg = '';
            $customerImg = '';
            $customerapplicationformImg = '';
            $baid = '';
            $installation_address = '';
            $customer_sla_id = 0;
            $validation_fields = array();
            
            $firstName = isset($this->payload->firstName) ? $this->payload->firstName : '';
            $lastName = isset($this->payload->lastName) ? $this->payload->lastName : '';
            $int_reseller_id = isset($this->payload->reseller_id) ? $this->payload->reseller_id : 0;
            $customerTypeId = isset($this->payload->customerTypeId) ? $this->payload->customerTypeId : 0;
            $gender = isset($this->payload->gender) ? $this->payload->gender : 0;
            $group_aasign = isset($this->payload->group) ? $this->payload->group : 0;
            $customer_sla_id = isset($this->payload->customer_sla_id) ? $this->payload->customer_sla_id : 0;
            $country = isset($this->payload->country) ? $this->payload->country : '';
            $state = isset($this->payload->state) ? $this->payload->state : 0;
            $district = isset($this->payload->district) ? $this->payload->district : 0;
            $city = isset($this->payload->city) ? $this->payload->city : 0;
            $email = isset($this->payload->email) ? $this->payload->email : '';
            $mobile = isset($this->payload->mobile) ? $this->payload->mobile : '';
            $pinCode = isset($this->payload->pin) ? $this->payload->pin : '';
            $address = isset($this->payload->address) ? $this->payload->address : ''; 
            $installation_address = isset($this->payload->installation_address) ? $this->payload->installation_address : '';
   
            $validation_fields = ['firstName'=>['isString', 'First Name'],'lastName'=>['isString', 'Last Name'],
                  'reseller_id'=>['isInteger', 'Reseller Id'],'customerTypeId'=>['isInteger', 'Customer Type Id'],
                  'gender'=>['isInteger', 'Gender'],'group'=>['isInteger', 'Group'],
                  'customer_sla_id'=>['isInteger', 'Customer SLA ID'],'country' => ['isString', 'Country'],
                  'state'=>['isInteger', 'State'],'district'=>['isInteger', 'District'],
                  'city'=>['isInteger', 'City'],'email' => ['isString', 'Email'],
                  'mobile' => ['isString', 'Mobile'],'pin' => ['isString', 'Pin Code'],
                  'address' => ['isString', 'Address 1'],'installation_address' => ['isString', 'Installation Address']];            
            $validation_fields['customerId'] = ['isInteger', 'Customer Id'];
            $customerId =  isset($this->payload->customerId) ? trim($this->payload->customerId) : ''; 
        
        
        
            $validation_fields['cafNumber'] = ['isString', 'CAF Number'];
            $caf_no = isset($this->payload->cafNumber)?trim($this->payload->cafNumber):'';
        
        
            $validation_fields['businessName'] = ['isString', 'Business Name'];
            $businessName = isset($this->payload->businessName)?trim($this->payload->businessName):'';
        

        
            $validation_fields['idType'] = ['isString', 'ID type'];
            $idType = isset($this->payload->idType)?trim($this->payload->idType):'';
        
        
            $validation_fields['idNumber'] = ['isString', 'ID Number'];
            $idNumber = isset($this->payload->idNumber)?trim($this->payload->idNumber):'';
        
        
            $validation_fields['fatherName'] = ['isString', 'Father Name'];
            $fatherName = isset($this->payload->fatherName)?trim($this->payload->fatherName):'';
        
        
            $validation_fields['discount'] = ['isString', 'Discount'];
            $discount = isset($this->payload->discount)?trim($this->payload->discount):0;
        
     
            $validation_fields['mandal'] = ['isString', 'Mandal'];
            $mandal = isset($this->payload->mandal)?trim($this->payload->mandal):'';
        
            
            $validation_fields['old_mobile'] = ['isString', 'Old Mobile'];
            $old_mobile = isset($this->payload->old_mobile)?trim($this->payload->old_mobile):'';
        
        
            $validation_fields['phone'] = ['isString', 'Phone Number'];
            $phoneNumber = isset($this->payload->phone)?trim($this->payload->phone):'';
        
       
            $validation_fields['address2'] = ['isString', 'Address2'];
            $address2 = isset($this->payload->address2)?trim($this->payload->address2):'';
        
        
            $validation_fields['address3'] = ['isString', 'Address3'];
            $address3 = isset($this->payload->address3)?trim($this->payload->address3):'';
        
        
            $validation_fields['remarks'] = ['isString', 'Remarks'];
            $remarks = isset($this->payload->remarks)?trim($this->payload->remarks):'';
        
        
            $validation_fields['installationAddress'] = ['isString', 'Installation Address'];
            $installationAddress = isset($this->payload->installationAddress)?trim($this->payload->installationAddress):'';
            
            if (isset($this->payload->dateofbirth) && !empty($this->payload->dateofbirth)) {
                $validation_fields['dateofbirth'] = ['isString', 'Date Of Birth'];
                $dateOfBirth = trim($this->payload->dateofbirth);
                $dateOfBirthExp = explode('-', $dateOfBirth);
                $d = $dateOfBirthExp[0];
                $m = $dateOfBirthExp[1];
                $y = $dateOfBirthExp[2];
            }
            if (isset($this->payload->dateofanniversary) && !empty($this->payload->dateofanniversary)) {
                $validation_fields['dateofanniversary'] = ['isString', 'Date Of Anniversary'];
                $dateOfAnniversary = trim($this->payload->dateofanniversary);
                $dateOfAnniversaryExp = explode('-', $dateOfAnniversary);
                $ad = $dateOfAnniversaryExp[0];
                $am = $dateOfAnniversaryExp[1];
                $ay = $dateOfAnniversaryExp[2];
            }
            
            
                $validation_fields['ipAddress'] = ['isString', 'IP Address'];
                $ipAddress = isset($this->payload->ipAddress)?trim($this->payload->ipAddress):'';
            
            
            
            $validation_fields['accountNumber'] = ['isString', 'Account Number'];
            $accountNumber = isset($this->payload->accountNumber)?trim($this->payload->accountNumber):'';
        
        
            $validation_fields['latitude'] = ['isString', 'Latitude'];
            $latitude = isset($this->payload->latitude)?trim($this->payload->latitude):'';
        
        
            $validation_fields['longitude'] = ['isString', 'Longitude'];
            $longitude = isset($this->payload->longitude)?trim($this->payload->longitude):'';
        
        
            $validation_fields['username'] = ['isString', 'Username'];
            $username = isset($this->payload->username)?trim($this->payload->username):'';
        
        
            $validation_fields['password'] = ['isString', 'Password'];
            $password = isset($this->payload->password)?trim($this->payload->password):'';
        
        
            $validation_fields['changeAddrs'] = ['isString', 'Change Address'];
            $change_addrs = isset($this->payload->changeAddrs)?trim($this->payload->changeAddrs):'';
        
        
            $validation_fields['customerVerification'] = ['isString', 'Customer Verification'];
            $customer_verification = isset($this->payload->customerVerification)?trim($this->payload->customerVerification):'';
            
                        
            $validation_fields['baid'] = ['isString', 'baid'];
            $baid = isset($this->payload->baid)?trim($this->payload->baid):'';
            

            $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload, $validation_fields);
            if(count($validation_response_array) > 0){  
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }



            //Validation end
            $str_customer_type_types_id = isset($this->payload->hotel_or_hospital) ? $this->payload->hotel_or_hospital:0;
            $int_country_code = isset($this->payload->txtcountry_code) ? $this->payload->txtcountry_code : 0;
            $str_type_cus_other = isset($this->payload->type_cus_other) ? $this->payload->type_cus_other : '';
            
            $int_language = isset($this->payload->sellanguage) ? $this->payload->sellanguage : 0;
            $double_installation_charges = isset($this->payload->installation_charges) ? $this->payload->installation_charges : 0.00;
            $double_stb_discount = isset($this->payload->txtdiscount) ? $this->payload->txtdiscount : 0.00;

            $discount_type = isset($this->payload->discount_type) ? $this->payload->discount_type : array();
            $discount_val = isset($this->payload->discount_val) ? $this->payload->discount_val : array();
            $discount_start_date = isset($this->payload->discount_start_date) ? $this->payload->discount_start_date : array();
            $discount_end_date = isset($this->payload->discount_end_date) ? $this->payload->discount_end_date : array();
            
            $array_dealer_setting = array();
            $result = array();
            $statusCode = 1;
            $errorCode="err_000";
            $statusMessage = 'Customer Updation failed.';
            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();
            log_message('debug', '==================customerinfo===========' . json_encode($this->payload));

            if ($employeeId != 0 && $dealerId != 0) {
                $obj = new wsModel();
                $cf_objj = new CommonFunctions();

                $userDetails = $obj->getusersDetails($dealerId, $employeeId);
                if (!empty($userDetails)) {
                    $str_login_users_type = $userDetails->users_type;
                    $str_login_employee_parent_type = $userDetails->employee_parent_type;
                    $int_login_employee_parent_id = $userDetails->employee_parent_id;
                    $login_employee_user_name = $userDetails->username;
                    $emp_first_name = $userDetails->first_name;
                    $emp_last_name = $userDetails->last_name;
                }
                $this->load->library('LovModel');
                $dealrSettings = $this->LovModel->getDelearSetting($dealerId);
                if (!empty($dealrSettings)) {
                    $array_dealer_setting = (array) $dealrSettings;
                }



                $this->load->model('Process_Model');
                $operation_name = 'customer_edit';
                $int_operation_id = $this->Process_Model->getoperation_id($operation_name, $dealerId);
                //$customer_data_response = $obj->getCustomerDetails($customerNumber='',$customerName='',$mobileNumber="",$boxNumber="",$startValue=0,$endValue=0,$lcoCustomerId="",$dealerId,$employeeId,$cafNumber="",$accountNumber,$vc_number="");
                $customerdetails = $this->CustomersModel->getDetails($customerId,$dealerId);
                if(!empty($customerdetails)){
                    if($country == ""){
                        $country = isset($customerdetails->country)?$customerdetails->country:"";
                    }
                    if($state == "" || $state == 0){
                        $state = isset($customerdetails->state)?$customerdetails->state:0;
                    }
                    if($city == "" || $city == 0){
                        $city = isset($customerdetails->city)?$customerdetails->city:0;
                    }
                    if($district == "" || $district == 0){
                        $district = isset($customerdetails->district)?$customerdetails->district:0;
                    }
                }
                //print_r($customerdetails);exit;
                $customer_details_array = array(
                    'business_name' => $businessName,
                    'first_name' => $firstName,
                    'last_name' => $lastName,
                    'father_Name' => $fatherName,
                    'username' => $username,
                    'password' => $password,
                    'mobile_no' => $mobile,
                    'email' => $email,
                    'address1' => $address,
                    'address2' => $address2,
                    'address3' => $address3,
                    'installation_address' => $installation_address,
                    'lco_customer_id' => $baid,
                    'account_number' => $accountNumber,
                    'phone_no' => $phoneNumber,
                    'pincode' => $pinCode,
                    'id_type' => $idType,
                    'id_number' => $idNumber,
                    'country_code' => $int_country_code,
                    'country' => $country,
                    'state' => $state,
                    'district' => $district,
                    'city' => $city,
                    'mandal' => $mandal,
                    'gender' => $gender,
                    'remarks' => $remarks,
                    'customersla_id' => $customer_sla_id,
                    'customer_type_id' => $customerTypeId,
                    'customer_type_description' => $str_type_cus_other,
                    'hotel_or_hospital' => $str_customer_type_types_id,
                    'longitude' => $longitude,
                    'latitude' => $latitude,
                    'year' => $y,
                    'month' => $m,
                    'date' => $d,
                    'ayear' => $ay,
                    'amonth' => $am,
                    'adate' => $ad,
                    'customer_id' => $customerId,
                    'bill_type' => $billType,
                    'online_customer' => 0,
                    'reseller_id' => $int_reseller_id,
                    'employeegroup' => $group_aasign,
                    'languages' => $int_language,
                    'installation_charges' => $double_installation_charges,
                    'stb_discount' => $double_stb_discount,
                    'caf_no' => $caf_no,
                    'discount_type' => $discount_type,
                    'discount_val' => $discount_val,
                    'discount_start_date' => $discount_start_date,
                    'discount_end_date' => $discount_end_date
                );
                $country_isd_code = $this->WsModel->getLovValue('COUNTRY_ISD_CODE',$dealerId);
                $validation_operations[0] = 'existing_customer_edit_validation';
                $login_emp_name = $emp_first_name . ' ' . $emp_last_name;
                $extra_parameters = array(
                    'dealer_id' => $dealerId,
                    'users_type' => $str_login_users_type,
                    'login_employee_id' => $employeeId,
                    'employee_parent_type' => $str_login_employee_parent_type,
                    'employee_parent_id' => $int_login_employee_parent_id,
                    'dealer_setting' => $array_dealer_setting,
                    'validation_operation_names' => $validation_operations,
                    'int_operation_id' => $int_operation_id,
                    'login_employee_user_name' => $login_employee_user_name,
                    'login_emp_name' => $login_emp_name,
                    'country_isd_code' => $country_isd_code
                );
                $keys=array();
                $values=array();
                foreach ($customer_details_array as $key => $value) {
                    $valid_data = 1;
                    if($value != ""){
                        if(($key == "state" || $key == "district" || $key == "city") && $value == 0){
                            $valid_data = 0;
                        }
                        if($valid_data){
                            $keys[]=$key;
                            $values[]=$value;
                            $customer_details_arrays=array_combine($keys,$values);
                        }
                    }
                }
               // $this->write_to_file("---------- customer edit customer_details_array---------".json_encode($customer_details_arrays));
                $data_for_operation = array(
                    'arr_customer_details' => $customer_details_arrays,
                    'extra_parameters' => $extra_parameters,
                    STATUS => SUCCESS,
                    ERR_CODE => 'SUC_0000',
                    ERR_MSG => 'Success'
                );
                //echo '<pre>';print_r($data_for_operation); exit;
                if (count($data_for_operation) > 0 && $int_operation_id > 0) {
                    $this->load->library('Workflow_lib');
                    $activity_id = 9; // activity name = edit_customer
                    $retn_data = $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $data_for_operation);
                }

                if(1==$data_for_operation[STATUS])$statusCode=0; else $statusCode=1;
               
                $errorCode= $data_for_operation[ERR_CODE];
                $statusMessage = $data_for_operation[ERR_MSG];
                if ('SUC_0000' == $data_for_operation['error_code']) 
                {
                    $statusCode = 0;
                    if (($this->post('idProofImg')) && !empty($this->post('idProofImg'))) 
                    {
                        $idProofImg = trim($this->post('idProofImg'));
                        $doc_type = $idType;
                        $file_name = 'idproof'.$customerId.$employeeId.date('YmdHis').'.jpeg';
                        $obj->imageUpdation(trim($file_name),trim($idProofImg),$customerId,$employeeId,$dealerId,$doc_type);
                    }
                    if (($this->post('customerImg')) && !empty($this->post('customerImg'))) 
                    {
                        $customerImg = trim($this->post('customerImg'));
                        $doc_type = 'CUSTOMER_IMAGE';
                        $file_name = 'customer'.$customerId.$employeeId.date('YmdHis').'.jpeg';
                        $obj->imageUpdation(trim($file_name),trim($customerImg),$customerId,$employeeId,$dealerId,$doc_type);
                    }
                    if (($this->post('signatureImg')) && !empty($this->post('signatureImg'))) 
                    {
                        $customerapplicationformImg = trim($this->post('signatureImg'));
                        $doc_type = 'CAF';
                        $file_name = 'caf'.$customerId.$employeeId.date('YmdHis').'.jpeg';
                        $obj->imageUpdation(trim($file_name),trim($customerapplicationformImg),$customerId,$employeeId,$dealerId,$doc_type);
                    }
                    $statusMessage = "Customer Details Updated Successfully";
                }
                
            } else {

                $statusMessage = 'Dealer or Employee does not exist.';
            }*/
            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();
            $customer_data = $this->WsModel->getCustomerDetails($this->payload->customerId,$customerName="",$mobileNumber="",$boxNumber="",$startValue="",$endValue="",$lcoCustomerId="",$dealerId,$employeeId,$cafNumber="",$account_number="",$vc_number="",'',0,$for_caf_entry=1);
            //print_r($customer_data);exit;
            // {"customer_sla_id":"1","lastName":"Tambekar","fatherName":"","country":"IN","gender":"0","city":"0","latitude":"17.4450409","businessName":"","boxNumber":"NSTV-SN22012","idNumber":"","customerTypeId":"2","pin":"673028","customerId":"160687","state":"0","installationAddress":"abcd nagar 1234 abc","old_mobile":"9527786191","email":"","reseller_id":"87","group":"74","longitude":"78.383282","dateofbirth":"0000-00-00","idType":"0","address":"abcd nagar 1234 abc, ","lcoCustomerId":"dsadsadsa","billType":"0","mobile":"9527786191","accountNumber":"C0160687","firstName":"Anitha","cafNumber":"NG123012","baid":"dsadsadsa","phone":"","district":"0","dateofanniversary":"0000-00-00","remarks":"CustomerUpdatedFromAndroidApp","mandal":""}
            if(!empty($customer_data)){
                $first_name = isset($this->payload->firstName) ? $this->payload->firstName : "";
                $_POST['First_Name_hidden']=$customer_data[0]->first_name;
                $_POST['First_Name']=(!empty($first_name))?$first_name:$customer_data[0]->first_name;

                $last_name = isset($this->payload->lastName) ? $this->payload->lastName : "";
                $_POST['Last_Name_hidden']=$customer_data[0]->last_name;
                $_POST['Last_Name']=(!empty($last_name))?$last_name:$customer_data[0]->last_name;

                $customerTypeId = isset($this->payload->customerTypeId) ? $this->payload->customerTypeId : $customer_data[0]->customer_type_id;
                $_POST['cus_type']=$customerTypeId;

                $lco_customer_id = isset($this->payload->lcoCustomerId) ? $this->payload->lcoCustomerId : "";
                $_POST['lco_customer_id_old']=$customer_data[0]->baid;
                $_POST['lco_customer_id']=(!empty($lco_customer_id))?$lco_customer_id:$customer_data[0]->baid;

                $group_aasign = isset($this->payload->group) ? $this->payload->group : $customer_data[0]->group_id;
                $_POST['group_aasign'] = $group_aasign;

                $email = isset($this->payload->email) ? $this->payload->email : $customer_data[0]->email;
                $_POST['email'] = $email;

                $mobile = isset($this->payload->mobile) ? $this->payload->mobile : $customer_data[0]->mobile_no;
                $_POST['mobile_no'] = $mobile;
                $_POST['mobile_no_hidden'] = $customer_data[0]->mobile_no;

                $id_type = isset($this->payload->idType) ? $this->payload->idType : "";
                $_POST['id_type_hidden']=$customer_data[0]->id_type;
                $_POST['id_type']=(!empty($id_type))?$id_type:$customer_data[0]->id_type;

                $id_number = isset($this->payload->idNumber) ? $this->payload->idNumber : "";
                $_POST['id_number_hidden']=$customer_data[0]->id_number;
                $_POST['id_number']=(!empty($id_number))?$id_number:$customer_data[0]->id_number;

                $customer_sla_id = isset($this->payload->customer_sla_id) ? $this->payload->customer_sla_id : "";
                $_POST['selsal_hidden']=$customer_data[0]->customersla_id;
                $_POST['selsal']=(!empty($customer_sla_id))?$customer_sla_id:$customer_data[0]->customersla_id;

                $address = isset($this->payload->address) ? $this->payload->address : "";
                $_POST['old_add1']=$customer_data[0]->address1;
                $_POST['Address1']=(!empty($address))?$address:$customer_data[0]->address1;
                //if($_POST['old_add1'] != $_POST['Address1']){
                    $_POST['change_addrs'] = "1";
                //}
                $installation_address = isset($this->payload->installationAddress) ? $this->payload->installationAddress : $customer_data[0]->installation_address;
                $_POST['installation_address']=(!empty($installation_address))?$installation_address:$customer_data[0]->address1;

                $pinCode = isset($this->payload->pin) ? $this->payload->pin : "";
                $_POST['old_pincode']=$customer_data[0]->pin_code;
                $_POST['Pin_Code']=(!empty($pinCode))?$pinCode:$customer_data[0]->pin_code;

                $country = isset($this->payload->country) ? $this->payload->country : "";
                $_POST['old_country']=$customer_data[0]->country;
                $_POST['country']=(!empty($country))?$country:$customer_data[0]->country;

                $state = isset($this->payload->state) ? $this->payload->state : "";
                $_POST['old_state']=$customer_data[0]->state;
                $_POST['state']=(!empty($state))?$state:$customer_data[0]->state;

                $district = isset($this->payload->district) ? $this->payload->district : "";
                $_POST['old_district']=$customer_data[0]->district;
                $_POST['district']=(!empty($district))?$district:$customer_data[0]->district;

                $city = isset($this->payload->city) ? $this->payload->city : $customer_data[0]->city;
                $_POST['old_city']=$customer_data[0]->city;
                $_POST['city']=(!empty($city))?$city:$customer_data[0]->city;

                $phone_no = isset($this->payload->phone) ? $this->payload->phone : "";
                $_POST['phone_no_hidden']=isset($customer_data[0]->phone_no)?$customer_data[0]->phone_no:"";
                $_POST['phone_no']=(!empty($phone_no))?$phone_no:$_POST['phone_no_hidden'];

                $mandal = isset($this->payload->mandal) ? $this->payload->mandal : "";
                $_POST['old_mandal']=isset($customer_data[0]->mandal)?$customer_data[0]->mandal:"";
                $_POST['mandal']=(!empty($mandal))?$mandal:$_POST['old_mandal'];

                $_POST['dateOfBirth'] = isset($this->payload->dateofbirth) ? $this->payload->dateofbirth : "";
                //$_POST['dateOfBirth']=(!empty($dateOfBirth))?$dateOfBirth:'0000-00-00';

                $anniversaryDate = isset($this->payload->dateofanniversary) ? $this->payload->dateofanniversary : "";
                $_POST['anniversaryDate']=(!empty($anniversaryDate))?$anniversaryDate:'0000-00-00';

                $_POST['father_Name'] = isset($this->payload->fatherName) ? $this->payload->fatherName : (isset($customer_data[0]->fathers_name)?$customer_data[0]->fathers_name:"");

                $_POST['txtbname'] = isset($this->payload->businessName) ? $this->payload->businessName : (isset($customer_data[0]->business_name)?$customer_data[0]->business_name:"");

                $_POST['caf_no'] = isset($this->payload->cafNumber) ? $this->payload->cafNumber : (isset($customer_data[0]->caf_no)?$customer_data[0]->caf_no:"");

                //caf_no

                //$_POST['country_code']="91";
                $this->load->model(array('CountryValidationModel'));
                $defaultCountry = $this->WsModel->getLovValue('DEFAULT_COUNTRY',$dealerId);
                $config_data_object = $this->CountryValidationModel->getCountryValidationByCode($defaultCountry);
                if(!empty($config_data_object)){
                    $config_values_array['country_code'] = !empty($config_data_object->getMobileCountryCode()) ? $config_data_object->getMobileCountryCode() : 91;
                }
                $_POST['country_code']=isset($config_values_array['country_code'])?$config_values_array['country_code']:"91";
                $this->load->model('CustomersModel');
                $extra_params['account_number'] = "";
                $extra_params['baid'] = $_POST['lco_customer_id'];
                $extra_params['dealer_id'] = $dealerId;
                //print_r($_POST);exit;
                write_to_file(" ================ Customer edit post data ================ ".json_encode($_POST));
                //print_r($this->post('idProofImg'));exit;
                $is_update=$this->CustomersModel->updateDetails($this->payload->customerId,$extra_params,$employeeId);
                //print_r($this->db->last_query());
                if(strpos($is_update,'successfully.') > 0){
                    $customerId = $this->payload->customerId;
                    if (($this->post('idProofImg')) && !empty($this->post('idProofImg'))) 
                    {
                        $idProofImg = trim($this->post('idProofImg'));
                        $doc_type = $id_type;
                        $file_name = 'idproof'.$customerId.$employeeId.date('YmdHis').'.jpeg';
                        $this->WsModel->imageUpdation(trim($file_name),trim($idProofImg),$customerId,$employeeId,$dealerId,$doc_type);
                    }
                    if (($this->post('customerImg')) && !empty($this->post('customerImg'))) 
                    {
                        $customerImg = trim($this->post('customerImg'));
                        $doc_type = 'CUSTOMER_IMAGE';
                        $file_name = 'customer'.$customerId.$employeeId.date('YmdHis').'.jpeg';
                        $this->WsModel->imageUpdation(trim($file_name),trim($customerImg),$customerId,$employeeId,$dealerId,$doc_type);
                    }
                    if (($this->post('signatureImg')) && !empty($this->post('signatureImg'))) 
                    {
                        $customerapplicationformImg = trim($this->post('signatureImg'));
                        $doc_type = 'CUSTOMER_SIGN';
                        $file_name = 'signature'.$customerId.$employeeId.date('YmdHis').'.jpeg';
                        $this->WsModel->imageUpdation(trim($file_name),trim($customerapplicationformImg),$customerId,$employeeId,$dealerId,$doc_type);
                    }
                    $statusCode = 0;
                    $errorCode = "";
                    $statusMessage = "Customer Details Updated Successfully";
                }
                else{
                    $statusCode = 1;
                    $errorCode = "";
                    $statusMessage = $is_update;
                }
            }
            else{
                $statusCode = 1;
                $errorCode = "";
                $statusMessage = 'Dealer or Employee does not exist.';
            }
            $response = array('status_code' => $statusCode,'error_code'=>$errorCode, 'status_msg' => $statusMessage);
            
            write_to_file(" ========== Edit Customer ========= ".json_encode($response));
            $encry_response = $this->encryption_lib->app_data_encryption($response);

            $this->response($encry_response, 200);
        } catch (Exception $e) {

            $this->error_res($e, 200);
        }
    }

    /**
     * API service:saveCustomerRest
     * @author RameshDudala 30-Dec-2021 updated by soujanya on 2023
     * @params {""customerId:Integer","customerTypeId:Integer","caf_no:String","businessName:String","firstName:String","lastName:String","idType:String","idNumber:String","fatherName:String","gender:String","group_aasign:String","discount:String","country:String","state:String","district:String","mandal:Integer","city:String","mobile:String","old_mobile:String","phoneNumber:String","email:String","pinCode:String","address:String","address2:String","address3:String","remarks:String","installationAddress:String","dateOfBirth:String","dateOfAnniversary:String","billType:String","ipAddress:String","pricingStructureType:String","validityDays:String","accountNumber:String","latitude=.0","longitude=.0","username:String","password:String","change_addrs:String","customer_verification:String","idProofImg:String","customerImg:String","customerapplicationformImg:String","baid:String","installation_address:String","customer_sla_id:Integer"}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
 **/  
    public function saveCustomerRest_post()
    {
		try
        {	
            $statusCode = 1;
            $statusMessage='';

            $employeeId = $this->getEmployeeId(); 
            $dealerId = $this->getDealerId();
            $validation_fields=array();
            
            $validation_fields['customerTypeId']=['isInteger','Customer Type Id'];
            $customerTypeId=isset($this->payload->customerTypeId)?trim($this->payload->customerTypeId):0;
            
            $validation_fields['cafNumber']=['isString','CAF Number'];
            $caf_no=isset($this->payload->cafNumber)?trim($this->payload->cafNumber):'';
            
            
            $validation_fields['businessName']=['isString','Business Name'];
            $businessName=isset($this->payload->businessName)?trim($this->payload->businessName):'';
            
           
            $validation_fields['firstName']=['isString','First Name'];
            $firstName=trim($this->payload->firstName)?trim($this->payload->firstName):'';
            
            
            $validation_fields['lastName']=['isString','Last Name'];
            $lastName=isset($this->payload->lastName)?trim($this->payload->lastName):'';
            
            
            $validation_fields['idType']=['isString','ID type'];
            $idType=isset($this->payload->idType)?trim($this->payload->idType):'';
            
            
            $validation_fields['idNumber']=['isString','ID Number'];
            $idNumber=isset($this->payload->idNumber)?trim($this->payload->idNumber):'';
            
            
            $validation_fields['fatherName']=['isString','Father Name'];
            $fatherName=isset($this->payload->fatherName)?trim($this->payload->fatherName):'';
            
            
            $validation_fields['gender']=['isString','Gender'];
            $gender=isset($this->payload->gender)?trim($this->payload->gender):'';
            
            
            $validation_fields['group']=['isString','Group'];
            $groupId=isset($this->payload->group)?trim($this->payload->group):'';
            
            
            $validation_fields['discount']=['isString','Discount'];
            $discount=isset($this->payload->discount)?trim($this->payload->discount):'';
            
            
            $validation_fields['country']=['isString','Country'];
            $country=isset($this->payload->country)?trim($this->payload->country):'';
            
            
            $validation_fields['state']=['isString','State'];
            $state=isset($this->payload->state)?trim($this->payload->state):'';
            
            
            $validation_fields['district']=['isString','District'];
            $district=isset($this->payload->district)?trim($this->payload->district):'';
            
            
            $validation_fields['mandal']=['isString','Mandal'];
            $mandal=isset($this->payload->mandal)?trim($this->payload->mandal):'';
            
            
            $validation_fields['city']=['isString','City'];
            $city=isset($this->payload->city)?trim($this->payload->city):'';
            
            
            $validation_fields['mobile']=['isString','Mobile'];
            $mobile=isset($this->payload->mobile)?trim($this->payload->mobile):'';
            
       
            
            $validation_fields['phone']=['isString','Phone Number'];
            $phoneNumber=isset($this->payload->phone)?trim($this->payload->phone):'';
            
            
            $validation_fields['email']=['isString','Email'];
            $email=isset($this->payload->email)?trim($this->payload->email):'';
            
            
            $validation_fields['pin']=['isString','PIN Code'];
            $pinCode=isset($this->payload->pin)?trim($this->payload->pin):'';
            
            
            $validation_fields['address']=['isString','Address'];
            $address=isset($this->payload->address)?trim($this->payload->address):'';
            
   
            
            $validation_fields['remarks']=['isString','Remarks'];
            $remarks=isset($this->payload->remarks)?trim($this->payload->remarks):'';
            
            
            $validation_fields['installationAddress']=['isString','Installation Address'];
            $installationAddress=isset($this->payload->installationAddress)?trim($this->payload->installationAddress):'';
            
            
            $validation_fields['idProofImg']=['isString','ID Proof image'];
            $idProofImg=isset($this->payload->idProofImg)?trim($this->payload->idProofImg):'';
            
            
            $validation_fields['customerImg']=['isString','Customer image'];
            $customerImg=isset($this->payload->customerImg)?trim($this->payload->customerImg):'';
            
            
            $validation_fields['signatureImg']=['isString','Signature image'];
            $customerImg=isset($this->payload->signatureImg)?trim($this->payload->signatureImg):'';
            
            
            $validation_fields['customerapplicationformImg']=['isString','Customer application form Img'];
            $customerapplicationformImg=isset($this->payload->customerapplicationformImg)?trim($this->payload->customerapplicationformImg):'';
            
            
            $validation_fields['boxNumber']=['isString','Box Number'];
            $boxNumber=isset($this->payload->boxNumber)?trim($this->payload->boxNumber):'';
            
            
            
            $validation_fields['packageId']=['isString','Package Id'];
            $packageId=isset($this->payload->packageId)?trim($this->payload->packageId):0;
            
            
            $validation_fields['dateType']=['isString','Date Type'];
            $dateType=isset($this->payload->dateType)?trim($this->payload->dateType):'';
            
            
            
            $validation_fields['quantity']=['isString','Quantity'];
            $quantity=isset($this->payload->quantity)?trim($this->payload->quantity):0;
            
            
            $validation_fields['dateofbirth']=['isString','Date Of Birth'];
            $dateOfBirth=isset($this->payload->dateofbirth)?trim($this->payload->dateofbirth):'';
            
            
            $validation_fields['dateofanniversary']=['isString','Date Of Anniversary'];
            $dateOfAnniversary=isset($this->payload->dateofanniversary)?trim($this->payload->dateofanniversary):'';
            
            
            $validation_fields['billType']=['isString','Bill Type'];
            $billType=isset($this->payload->billType)?trim($this->payload->billType):'';
            
            
            $validation_fields['customerTypeTypesId']=['isString','Bill Type'];
            $customerTypeTypesId=isset($this->payload->customerTypeTypesId)?trim($this->payload->customerTypeTypesId):'';
            
          
            $validation_fields['ipAddress']=['isString','IP Address'];
            $ipAddress=isset($this->payload->ipAddress)?trim($this->payload->ipAddress):'';
            
            
            $validation_fields['pricingStructureType']=['isString','Pricing Structure Type'];
            $pricingStructureType=isset($this->payload->pricingStructureType)?trim($this->payload->pricingStructureType):'';
            
            
            $validation_fields['validityDays']=['isString','Validity Days'];
            $validityDays=isset($this->payload->validityDays)?trim($this->payload->validityDays):'';
            
            
            $validation_fields['accountNumber']=['isString','Account Number'];
            $accountNumber=isset($this->payload->accountNumber)?trim($this->payload->accountNumber):'';
            
            
            $validation_fields['latitude']=['isString','Latitude'];
            $latitude=isset($this->payload->latitude)?trim($this->payload->latitude):'';
            
            
            $validation_fields['longitude']=['isString','Longitude'];
            $longitude=isset($this->payload->longitude)?trim($this->payload->longitude):'';
            
            
            $validation_fields['username']=['isString','Username'];
            $username=isset($this->payload->username)?trim($this->payload->username):'';
            
            
            $validation_fields['password']=['isString','Password'];
            $password=isset($this->payload->password)?trim($this->payload->password):'';
            
            
            $validation_fields['lcoCustomerId']=['isString','LCO Customer Id'];
            $lcoCustomerId=isset($this->payload->lcoCustomerId)?trim($this->payload->lcoCustomerId):'';
            
            
            $validation_fields['customerId']=['isString','Customer Id'];
            $customerId=isset($this->payload->customerId)?trim($this->payload->customerId):0;
            
            $validation_fields['is_surrender']=['isString','Is Surrender'];
            $is_surrender=isset($this->payload->is_surrender)?trim($this->payload->is_surrender):0;
            
            $validation_fields['packageEndDate']=['isString','Packege end date'];
            $packageEndDate=isset($this->payload->packageEndDate)?trim($this->payload->packageEndDate):'';

            $validation_fields['resellerId']=['isString','Reseller Id'];
            $int_reseller_id=isset($this->payload->resellerId)?trim($this->payload->resellerId):'';
            
            $validation_response_array =   $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
            if(count($validation_response_array) > 0){  
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }

            $this->load->model(array('CustomersModelNew','NewCustomerWithStbModel','WsModel','Change_pass_model','Migration_model','Process_Model','LovModel'));
            $this->load->library(array('prepare_activation_postdata_lib','workflow_lib'));
            //log_message("debug","===============POSTDATA=====================".json_encode($arr_cust_details));
            $double_stb_discount = 0;
            $int_stb_count =0;
            //Validation end
            //$data_for_operation = $this->prepare_customer_post_data($customerInfo, $dealerId, $employeeId);
            $defaultCountry = $this->WsModel->getLovValue('COUNTRY_ISD_CODE',$dealerId);
            $stock_id = $this->WsModel->getStockIds($boxNumber, $dealerId);
            $customer_details_array = array(
            'business_name' => $businessName,
            'first_name' => $firstName,
            'last_name' => $lastName,
            'father_Name' => $fatherName,
            'username' => $username,
            'password' => $password,
            'mobile_no' => $mobile,
            'email' => $email,
            'address1' => $address,
            'address2' => '',
            'address3' => '',
            'installation_address' => $installationAddress,
            'lco_customer_id' => $lcoCustomerId,
            'account_number' => $accountNumber,
            'phone_no' => $phoneNumber,
            'pincode' => $pinCode,
            'id_type' => $idType,
            'id_number' => $idNumber,
            'country_code' => $defaultCountry,
            'country' => $country,
            'state' => $state,
            'district' => $district,
            'city' => $city,
            'mandal' => $mandal,
            'gender' => $gender,
            'remarks' => $remarks,
            'customersla_id' => 0,//$int_sla,
            'customer_type_id' => $customerTypeId,
            'customer_type_description' => '',//$str_type_cus_other,
            'hotel_or_hospital' => $customerTypeId,
            'longitude' => $longitude,
            'latitude' => $latitude,
            'dateOfBirth' => $dateOfBirth,
            'anniversaryDate' => $dateOfAnniversary,
            'customer_id'=>$customerId,
            'online_customer'=>0,
            'reseller_id' => $int_reseller_id,// Need to send
            'employeegroup' => $groupId,
            'languages' => '',//$int_language,
            'installation_charges' => 0,//$double_installation_charges,
            'stb_discount' => 0,//$double_stb_discount,
            'caf_no' => $caf_no,
            'int_discount_type' => $discount,
            'double_discount_val' => '',//$double_discount_val,
            'discount_start_date' => '',//$discount_start_date,
            'discount_end_date' => '',//$discount_end_date,
            'stb_count'=>$int_stb_count 
        );
            $dataForPreparePost = array();
            $dataForPreparePost['boxNumber'] =$boxNumber;
            $dataForPreparePost['username'] =$username;
            $dataForPreparePost['password'] =$password;
            $dataForPreparePost['pinCode'] =$pinCode;
            $dataForPreparePost['email'] =$email;
            $dataForPreparePost['packageId'] =$packageId;
            $dataForPreparePost['quantity'] =$quantity;
            $dataForPreparePost['stock_id'] =$stock_id;
    
            $data_for_operation = $this->prepare_customer_post_data($dataForPreparePost, $dealerId, $employeeId);
            $data_for_operation['arr_customer_details'] = $customer_details_array;
            //print_r($data_for_operation);exit;
			if($employeeId != 0 && $dealerId != 0)
			{
			    $obj = new WsModel(); 	
                $int_operation_id= $this->Process_Model->getoperation_id('customer_creation_from_app',$dealerId);
                $data_for_operation['extra_parameters']['int_operation_id'] = $int_operation_id;
				//$int_operation_id = $int_operation_id = isset($data_for_operation['extra_parameters']['int_operation_id'])?$data_for_operation['extra_parameters']['int_operation_id']:0;;
                    //print_r($arr_act_cas_productIds);exit;
                $activity_id = 3; // activity name = Service Activation
                $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $data_for_operation);
                //print_r(json_encode($data_for_operation));exit;
                $int_customer_id = isset($data_for_operation['arr_customer_details']['customer_id'])?$data_for_operation['arr_customer_details']['customer_id']:0;                
				if(getStatus($data_for_operation[STATUS]) && $int_customer_id>0)
				{
                    if(isset($int_customer_id) && $int_customer_id > 0)
					{
						if (($this->post('idProofImg')) && !empty($this->post('idProofImg'))) 
                        {
                            $idProofImg = trim($this->post('idProofImg'));
                            $doc_type = $idType;
                            $file_name = 'idproof'.$int_customer_id.$employeeId.date('YmdHis').'.jpeg';
                            $obj->imageUpdation(trim($file_name),trim($idProofImg),$int_customer_id,$employeeId,$dealerId,$doc_type);
                        }
                        if (($this->post('customerImg')) && !empty($this->post('customerImg'))) 
                        {
                            $customerImg = trim($this->post('customerImg'));
                            $doc_type = 'CUSTOMER_IMAGE';
                            $file_name = 'customer'.$int_customer_id.$employeeId.date('YmdHis').'.jpeg';
                            $obj->imageUpdation(trim($file_name),trim($customerImg),$int_customer_id,$employeeId,$dealerId,$doc_type);
                        }
                        if (($this->post('signatureImg')) && !empty($this->post('signatureImg'))) 
                        {
                            $customerapplicationformImg = trim($this->post('signatureImg'));
                            $doc_type = 'CAF';
                            $file_name = 'caf'.$int_customer_id.$employeeId.date('YmdHis').'.jpeg';
                            $obj->imageUpdation(trim($file_name),trim($customerapplicationformImg),$int_customer_id,$employeeId,$dealerId,$doc_type);
                        }
					}	
                    $statusMessage =  'Customer Created Successfully.';
                    $statusCode = 0;			
				}
				else
				{
                    $statusCode = 1;
                    $statusMessage = isset($data_for_operation['error_message'])?$data_for_operation['error_message']:"Customer creation failed.";
                }       			
			}
			else
			{
				$statusMessage = 'Dealer or Employee does not exist.';		
			}     
            $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);
            $this->sendResponse($response);
        } 
        catch(Exception $e)
        {
           $this->error_res($e, 200);
        }                      
    }		
    public function prepare_customer_post_data($customerInfo, $dealerId, $employeeId)
    {
        $this->load->model(array('NewCustomerWithStbModel','WsModel','Migration_model','Process_Model','LovModel'));
        $arr_plugin_details = array();
        $arr_cas_serial_number = array();
        $selected_plugin_id =4;
        $statusCode = 1;
        $statusMessage ='';
        $boxNumber = isset($customerInfo['boxNumber'])?$customerInfo['boxNumber']:'';
        $username = isset($customerInfo['username'])?$customerInfo['username']:'';
        $password = isset($customerInfo['password'])?$customerInfo['password']:'';
        $pinCode = isset($customerInfo['pinCode'])?$customerInfo['pinCode']:'';
        $email = isset($customerInfo['email'])?$customerInfo['email']:'';
        $packageId = isset($customerInfo['packageId'])?$customerInfo['packageId']:0;
        $quantity = isset($customerInfo['quantity'])?$customerInfo['quantity']:0;
        $stock_id = isset($customerInfo['stock_id'])?$customerInfo['stock_id']:0;
        if($stock_id > 0){
            // Get Serial number from DB ,lowercase issue from LCO Mobile app due to this serial number comparision fails
            $serial_number_object = $this->WsModel->getSerialNumber($stock_id);
            if(!empty($serial_number_object)){
                $boxNumber = isset($serial_number_object->serial_number)?$serial_number_object->serial_number:$boxNumber;
            }

        }
        $this->load->library(array('prepare_activation_postdata_lib'));
        //write_to_file("here in save customer");
        if(4 == $selected_plugin_id)
        {   // CAS
            // New box
            $str_cas_serial_number = $boxNumber;
            if(!($str_cas_serial_number!='')){
                $statusMessage = "Please Enter Box Number";
                $statusCode = 1;
                $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);
                throw new Exception($statusMessage);
            }
            else
            {
                //start - plugin details array
                $arr_plugin_details['CAS']['box_selection']= 'new';    
                $arr_cas_serial_number[] = $boxNumber;                        
                $arr_plugin_details['CAS']['arr_cas_serial_number']= $arr_cas_serial_number;
            //end - plugin details array
            }                    
        }
        $validation_operations = array();                        
        $validation_operations[0]='new_customer_validation';
        $validation_operations[1]='new_box_validation';
        $validation_operations[2]='new_customer_package_validation';
        $arr_cas_productIds = array();
        $array_dealer_setting = $this->setDealerSetting($this->LovModel->getDelearSetting($dealerId));
        $operation_name = 'customer_app';
        $int_operation_id= $this->Process_Model->getoperation_id($operation_name,$dealerId);
        $int_act_reason_id = 4;
        $str_act_remarks = 'CAF Upload';
        $arr_form_validations = $this->CustomersModel->getCustomerFormValidation('customer','',$dealerId);
        $user_data = $this->WsModel->getUserDetails($employeeId,$dealerId);
        $user_type =$user_data->users_type;
        $employee_parent_type =$user_data->employee_parent_type;
        $employee_parent_id =$user_data->employee_parent_id;
        $extra_parameters = array(
            'dealer_id' => $dealerId,
            'users_type' => $user_type,
            'login_employee_id' => $employeeId,
            'employee_parent_type' => $employee_parent_type,
            'employee_parent_id' => $employee_parent_id,
            'dealer_setting' => $array_dealer_setting,
            'validation_operation_names'=>$validation_operations,
            'user_name' => $username,
            'password' => $password,
            'email' => $email,
            'pin_code' => $pinCode,
            'int_operation_id'=>$int_operation_id,
            'int_act_reason'=>$int_act_reason_id,
            'str_act_remarks'=>$str_act_remarks,
            'form_validations'=>$arr_form_validations,
            'arr_special_charges'=>['INSTALLATION_CHARGES', 'NCF_ENCF'],
        );
        $arr_product_details = array();                               
        $arr_rule_set_info = $this->Migration_model->getRuleSetInfo($packageId, $dealerId, $employeeId);
        //print_r($arr_rule_set_info);
        $rule_set_info = array();
        if(!empty($arr_rule_set_info)){
            foreach($arr_rule_set_info as $row){
                $rule_set_info = isset($row->rule_set_info)?$row->rule_set_info:array();
            }
        }
        
        $extra_info = array('stock_id'=>$stock_id,'extra_quantity'=>$quantity,'dealer_id'=>$dealerId);
        $product_data = $this->prepare_activation_postdata_lib->getProductProperties($rule_set_info, $extra_info);
        $arr_product_details['cas_package'][$stock_id][$packageId] = $product_data;
        
        $enum_add_on_after_base = isset($array_dealer_setting['ADDON_AFTER_BASEPACK']) ? $array_dealer_setting['ADDON_AFTER_BASEPACK'] : 0;
        $int_end_time = isset($array_dealer_setting['SERVICE_ENDTIME'])?$array_dealer_setting['SERVICE_ENDTIME']:0;
         $service_enddate_time = isset($array_dealer_setting['SERVICE_ENDDATE_TIME'])?$array_dealer_setting['SERVICE_ENDDATE_TIME']:'23:59:59';

        $extra_params_postdata = [
        'array_dealer_setting'=>$array_dealer_setting,
        'enum_add_on_after_base'=>$enum_add_on_after_base,
        'double_stb_discount'=>0,
        'reseller_id' => $employeeId,
        'int_customer_id' => 0,
        'end_time' => $int_end_time,
        'service_enddate_time'=>$service_enddate_time 
        ];

        $arr_final_result = $this->prepare_activation_postdata_lib->prepareDataForActivation($dealerId, $arr_product_details, $extra_params_postdata);  
        $arr_plugin_wise_product_info = (isset($arr_final_result['arr_plugin_wise_product_info']) && count($arr_final_result['arr_plugin_wise_product_info'])>0)?$arr_final_result['arr_plugin_wise_product_info']:[];
        $arr_stb_details = (isset($arr_final_result['arr_stb_details']) && count($arr_final_result['arr_stb_details'])>0 ) ? $arr_final_result['arr_stb_details']:[];

        $data_for_operation = array(
            //'arr_customer_details' => $customer_details_array,
            'arr_plugin_details' => $arr_plugin_details,
            'extra_parameters' => $extra_parameters,
            'arr_box_details' => $arr_stb_details,                    
            'arr_act_package_details'=>$arr_plugin_wise_product_info,
            STATUS=>SUCCESS,
            ERR_CODE=>'SUC_0000',
            ERR_MSG=>'Success'
        );  
        return $data_for_operation;
    }
      public function setDealerSetting($settings)
      {
        $aSettings=array();
        for($i = 0; $i<count($settings);$i++){
                $aSettings[$settings[$i]->setting] = $settings[$i]->value;
        }
        return $aSettings;
    }
     /**
     * API service:getExpiryServicesDateWiseCount
     * @author RameshDudala 11-Janaury-2022
     * Params{}
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'arr_getExpiryServicesList'=>$arr_getExpiryServicesList)
 **/
  public function  getExpiryServicesDateWiseCount_post()
    {
         try{	
                    $statusCode = 1;
                    $statusMessage='';
                    $arr_getExpiryServicesList=array();
                    
                    $this->load->model('WsModel');
      

        $employeeId = $this->getEmployeeId(); 
        $dealerId = $this->getDealerId();
        
        if($employeeId>0 && $dealerId>0){
            //get the expiry services list
            $arr_getExpiryServicesList = $this->WsModel->getExpiryServicesCount($dealerId,$plugin_id=4,$employeeId);
            write_to_file(" =============== getExpiryServicesCount query ============== ".json_encode($arr_getExpiryServicesList));
            //echo $this->db->last_query(); exit;
            if(!empty($arr_getExpiryServicesList))
            {
                $statusCode = 0;
                $statusMessage = 'Success';
            }else{
                $statusMessage = 'No Expiry Services';
            }
        } else{
            $statusMessage = 'Authentication Failed';
        }
        
        
         $response =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'getExpiryServicesList' => $arr_getExpiryServicesList);
           $encry_response = $this->encryption_lib->app_data_encryption($response);
         $this->response($encry_response, 200);
        } catch(Exception $e)
             {
                    
                $this->error_res($e, 200);
       }  
    }
    
    
 public function integer_val($element,$Fname){
         if(is_int($element)){
                  return array('status'=>true);  
          }else{
              $array=array('status'=>false,'errro_msg'=>"The ".$Fname." is not a integer or not valid");
                   return $array;  
          }
 }
//end ramesh
 
 //function to get the district locations
        /**
     * get Locations Of District soap to rest conversion
     * @author Vyshnavi 21-12-2021 updated by soujanya on 10-7-2023
     * @params districtId 178
     * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'districtLocationsList'=>$districtLocationsList))
     */
		public function getLocationsOfDistrictRest_post()
		{
                    try{
                        //validations
                        $validation_fields=['districtId'=>['isInteger|isRequired','District Id']];
                       $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);

                       if(count($validation_response_array) > 0){
                            // validation error
                            
                            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                            $response = array(  'status_code'=>$statusCode,
                                                'status_msg'=>$statusMessage
                                            );
                            $this->sendResponse($response);
                        }
                          //Validation end
			$obj = new WsModel();
			//Get the dealer_id and employee_id from auth token
			$employeeId = $this->getEmployeeId();
                        $dealerId = $this->getDealerId();
                        $districtId = trim($this->payload->districtId);
                        
			if($employeeId != 0 && $dealerId != 0)
			{
				$res = $obj->getLocationsOfDistrict($districtId);
				$districtLocationsList = array();
				if(!empty($res))
				{
					$statusCode = 0;
					$statusMessage = 'Success';
					foreach($res as $k=>$v)
					{
						$districtLocationsList[$k]=$v;
					}
				}
				else
				{
					//$statusCode = 1;
					$statusMessage = 'No records found.';
					//$districtLocationsList[0] = (object)array('location_id'=>'','location_name'=>'','district_id'=>'','mandal_id'=>'');
				}
			}
			else
			{
				//$statusCode = 1;
				$statusMessage = 'Dealer or Employee does not exist';
				//$districtLocationsList[0] = (object)array('location_id'=>'','location_name'=>'','district_id'=>'','mandal_id'=>'');
			}
                      
                        $response = (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'districtLocationsList'=>$districtLocationsList));
                        $this->sendResponse($response);	
		}
                catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
        }
        
        //get products
    /**
     * get Cas Packages soap to rest conversion
     * @author Vyshnavi 21-12-2021 updated by soujanya 10-7-2023
     * @params boxNumber 22619080127534 (dealerId 1  employeeId 39)
     * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'caspackageList'=>$caspackageList))
     */
	public function getCasPackagesRest_post()
    {
            try {
                //validations
                $validation_fields=['boxNumber'=>['isString|isRequired','Box Number']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                  //Validation end

        $obj = new WsModel();
        $this->load->model(array('NewCustomerWithStbModel'));
        //Get the dealer_id and employee_id from auth token
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                $boxNumber = trim($this->payload->boxNumber);
                //print_r($boxNumber);exit;
        //print_r($boxNumber);
        $resultArr = array();       
        if($employeeId != 0 && $dealerId != 0)
        {
            $stokDetails = $obj->stockDetails($boxNumber);
           // print_r($stokDetails);
            if (!empty($stokDetails)) {
                $stock_id = $stokDetails->stock_id;
                $backend_setup_id = $stokDetails->backend_setup_id;
                $stb_type_id = $stokDetails->stb_type_id;
                $resultArr = $this->NewCustomerWithStbModel->get_customerservice_products($customerId=0, $backend_setup_id, $str_product_list="", $dealerId, $stb_type_id, $stock_id, $userType="RESELLER", $setting_value=1, $employeeId, $sort_order_val=1, $flag=0,$plugin_id=4,$product_date='',$default_verification=1);
            }
            $caspackageList = array();
            if(!empty($resultArr))
            {
                $statusCode = 0;
                $statusMessage = 'Success';
                $i = 0;
                $addon_after_base = $this->WsModel->getLovValue('ADDON_AFTER_BASEPACK',$dealerId);
                foreach ($resultArr as $k => $value) {
                    $ruleset_data=json_decode($value->rule_set_info,true);
                    if($addon_after_base == 0 || (isset($value->is_base_package) && $value->is_base_package == 1)){
                        $caspackageList[$i] = array("product_id"=>$value->product_id,"pname"=>$value->pname,"base_price"=>$value->base_price,"sd_channels_count"=>$value->sd_channels_count,"hd_channels_count"=>$value->hd_channels_count,"is_base_package"=>$value->is_base_package,"is_broadcaster_package"=>$value->is_broadcaster_package,"alacarte"=>$value->alacarte,"monthly_or_yearly"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes'][0]['customer_service_duration_name'],"validity"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes'][0]['customer_service_duration_name'],"validity_days"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes'][0]['RuleSetTransAttrib'][0]['duration_limit'],'pricing_structure_type'=>2,"is_taxble"=>0,"tax1"=>0,"tax2"=>0,"tax3"=>0,"tax4"=>0,"tax5"=>0,"tax6"=>0,"broadcaster_id"=>0);
                        $i = $i + 1;
                    }
                }
            }
            else
            {
                $statusCode = 1;
                $statusMessage = 'No records found.';
                //$caspackageList[0] = (object)array('packageId'=>'','packageName'=>'','pricingStructureType'=>'');
            }
        }
        else
        {
            $statusCode = 1;
            $statusMessage = 'No records found.';
            //$caspackageList[0] = (object)array('packageId'=>'','packageName'=>'','pricingStructureType'=>'');
        }
             
        
                $response = array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'caspackageList'=>$caspackageList);
                //print_r($response);exit;
                $this->sendResponse($response);
    }
        catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
}
 
//function to validate box info by rakesh on 03-12-2013
    /**
     * validate box info soap to rest conversion
     * @author Vyshnavi 20-12-2021  updated by soujanya on 10-7-2023
     * @params boxNumber 
     * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'boxNumber'=>$boxNumber,'resellerId'=>$resellerId))
     */
        public function validateBoxInfoRest_post()
        {
            try
            {
                //validations
                $validation_fields=['boxNumber'=>['isString|isRequired','Box Number']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                     //   validation
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }
                //Validation end
                $obj = new WsModel();
                $resellerId = 0;
                $messageList = array('0'=>'Success',
                                    '1'=>'Box does not exist',
                                    '2'=>'Box is defective',
                                    '3'=>'Box is in trash',
                                    '4'=>'Box is not paired',
                                    '5'=>'Box is surrendered',
                                    '6'=>'Box is assigned to some other customer',
                                    '7'=>'',
                                    '8'=>'You do not have authorization',
                                    '9'=>'Dealer or Employee does not exist',
                                   );
                //Get the dealer_id and employee_id from auth token
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                $boxNumber=trim($this->payload->boxNumber);
              
                if($employeeId != 0 && $dealerId != 0)
                {
                    /*$access = $obj->accessControl($employeeId,$dealerId);
                    if(count($access) > 0 && $access->CUSTOMERS->create == 1)
                    {*/

                        $resellerId = $obj->getResellerId($boxNumber,$dealerId);
                        $result = $obj->validateBoxInfo($boxNumber,$employeeId,$dealerId,$resellerId);

                        if($result == 7)
                        {

                                $statusCode = 0;
                                $statusMessage = $messageList[0];
                        }
                        else
                        {
                                $statusCode = 1;
                                $statusMessage = $messageList[$result];
                        }
                    /*}
                    else
                    {
                        $statusCode = 1;
                        $statusMessage = $messageList[8];		
                    }	*/
                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = $messageList[9];	
                }
                

                $response =array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'boxNumber'=>$boxNumber,'resellerId'=>$resellerId);
                $this->sendResponse($response);
        }
        catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
        }
        
        //code to send the form validations to app after login written by chakri
        /**
     * dynamic form validations soap to rest conversion
     * @author Vyshnavi 20-12-2021 updated by soujanya on 10-7-2023
     * @params table_name eb_stock
     * @return (array('status_msg'=>$final_response))
     */
        
    public function dynamicformvalidationsRest_post()
    {
        try
        {
            //validations
            $validation_fields=['table_name'=>['isString|isRequired','Table Name']];
            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
            
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }

            //code to get the data from eb_form_validations table
            $obj = new WsModel();
            $response = array();
            $final_response = '';
            $dealer_id = $this->getDealerId();
            $table_name = trim($this->payload->table_name);
            if($dealer_id > 0)
            {
                $response = $obj->getebFormValidations($dealer_id,$table_name);
                if(isset($response) && count($response) >0)
                {
                    $final_response =  ($response);
                }
                //return (array('status_msg'=>$final_response));
                $response =(array('status_msg'=>$final_response));
                $this->sendResponse($response);
            }
        }
        catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    }
 
    /**
     * Daily Report soap to rest conversion
     * @author Vyshnavi 20-12-2021 updated by soujanya on 10-7-2023
     * @params dealer_id 1 || date 2021-07-04
     * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'Dailyreport_details'=>$Dailyreport_details))
     */
    
   public function DailyreportRest_post(){
       try{
            $validation_fields=['dealer_id'=>['isInteger|isRequired','Dealer Id'],'date'=>['checkValidDate|isRequired','Date']];
            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
              // validation count
           if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

            $obj = new WsModel();
            $dealer_id=trim($this->payload->dealer_id);
            $date=isset($this->payload->date)?(trim($this->payload->date)):'';
            $employeeId = $this->getEmployeeId();
            $userType = $obj->getUserType($employeeId,$dealer_id);
            $Dailyreport_details=array();
         
            if($employeeId != 0 && $dealer_id != 0 )
		{
           
			$response_details=$obj->Dailyreport_list_Service($dealer_id,$employeeId,$date,$userType);
            write_to_file(" =========== Dailyreport_list_Service query ======= ".$this->db->last_query());
			if(!empty($response_details))
			{
				$statusCode = 0;
				$statusMessage = 'Success';
				foreach($response_details as $k=>$v)
				{
					$Dailyreport_details[$k]=$v;
				}
			}
			else{
				$statusCode = 1;
				$statusMessage = 'Empty payment list';
			}
		}
		else{
		$statusCode = 1;
			$statusMessage = 'Not a valid customer';
		}
        
	$response =array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'Dailyreport_details'=>$Dailyreport_details);
        $this->sendResponse($response);
    }
    catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
   }
    
   /**
     * emp collection soap to rest conversion
     * @author Vyshnavi 16-12-2021 updated by soujanya on 10-7-2023
     * @params dealer_id 1 , fromDate 2021-07-04 and toDate 2021-07-04 employeeId 39
     * JWT username KDN0034 || password 1234 || Resellerid 39 
     * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'Dailyreport_details'=>$Dailyreport_details))
     */

        public function empCollectionRest_post() {
            try{
                $validation_fields=['dealer_id'=>['isInteger|isRequired','Dealer Id'],'fromDate'=>['checkValidDate|isRequired','From Date'],'toDate'=>['checkValidDate|isRequired','To Date']];
            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
               // validation count
           if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

            $obj = new WsModel();
            $employeeId = $this->getEmployeeId();
            $dealerId=trim($this->payload->dealer_id);
            $fromDate=isset($this->payload->fromDate)?trim($this->payload->fromDate):date('Y-m-01');
            $toDate=isset($this->payload->toDate)?trim($this->payload->toDate):date('Y-m-t');
            $customerInfo = (object)array('fromDate'=>$fromDate, 'toDate'=>$toDate);
            $collectionList = array();
            //write_to_file("empCollection");
       
            if ($employeeId != 0 && $dealerId != 0) {
                    $access = $obj->accessControl($employeeId, $dealerId);
                    $userType = $obj->getUserType($employeeId,$dealerId);	    
                    if (!empty($access) > 0 && $access->COLLECTIONS->view == 1) {
                            $result = $obj->getEmployeeCollection($customerInfo, $employeeId, $dealerId,$userType);
                            write_to_file(" ============ getEmployeeCollection query ======== ".$this->db->last_query());
                            if (!empty($result)) {
                                    $statusCode = 0;
                                    $statusMessage = 'Success';
                                    foreach ($result as $k => $v) {
                                            $collectionList[$k] = $v;
                                    }
                            } else {
                                    //$statusCode = 1;
                                    $statusMessage = 'No records found.';
                                    $collectionList[0] = (object) array('employeeId' => '', 'employeeName' => '', 'collectionAmount' => '');
                            }
                    } else {
                            //$statusCode = 1;
                            $statusMessage = 'No records found.';
                            $collectionList[0] = (object) array('employeeId' => '', 'employeeName' => '', 'collectionAmount' => '');
                    }
            } else {
                   // $statusCode = 1;
                    $statusMessage = 'No records found.';
                    $collectionList[0] = (object) array('employeeId' => '', 'employeeName' => '', 'collectionAmount' => '');
            }

            $response =array('status_code' => $statusCode, 'status_msg' => $statusMessage, 'collectionList' => $collectionList);
            $this->sendResponse($response);
    }
    catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
        }
        
        //function to get customer type types 
        /**
        * get customer Type Types soap to rest conversion
        * @author Vyshnavi 23-12-2021 updated by soujanya on 10-7-2023
        * @params resellerId 39 customerTypeId 1
        * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'idList'=>$idList))
        */  
	public function getcustomerTypeTypesRest_post()
	{
            try
            {
                //validations
                $validation_fields=['resellerId'=>['isInteger|isRequired','Reseller Id'],'customerTypeId'=>['isInteger|isRequired','CustomerType Id']];
               $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                  //Validation end
		$obj = new WsModel();
		//Get the dealer_id and employee_id from auth token
		$employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
		$resellerId = trim($this->payload->resellerId);
		$customerTypeId =trim($this->payload->customerTypeId);
        
		if($employeeId != 0 && $dealerId != 0 && $resellerId != 0 && $customerTypeId != 0)
		{
                    $res = $obj->getCustomerTypeOfTypes($resellerId,$customerTypeId);
                    if(isset($res) && !empty($res) )
                    {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                        foreach($res as $k=>$v)
                        {
                            $customerTypeTypesInfoList[$k]=$v;
                        }
                    }
                    else
                    {
                        $customer_obj = new CustomersModel();
                        $statusCode = 1;
                        $statusMessage = $customer_obj->displayAlert($dealerId);
                        $customerTypeTypesInfoList[0] = (object)array('customerTypeTypesId'=>'','name'=>'');
                    }
		}
		else
		{
                    $statusCode = 1;
                    $statusMessage = 'Dealer or Employee does not exist';
                    $customerTypeTypesInfoList[0] = (object)array('customerTypeTypesId'=>'','name'=>'');		
		}
              
                $response = array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'customerTypeTypesInfoList'=>$customerTypeTypesInfoList);
                $this->sendResponse($response);
	}
        catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    }
    
    //function to get the id types by rakesh on 06-12-2013
    /**
        * get Ids soap to rest conversion
        * @author Vyshnavi 23-12-2021
        * @params void
        * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'idList'=>$idList))
        */ 
		public function getIdsRest_post()
		{
                    try{
			$obj = new WsModel();
			//Get the dealer_id and employee_id from auth token
			$employeeId = $this->getEmployeeId();
                        $dealerId = $this->getDealerId();
                       
			if($employeeId != 0 && $dealerId != 0)
			{
				$res = $obj->getIds($dealerId);
				$idList = array();
				if(count($res)>0)
				{
					$statusCode = 0;
					$statusMessage = 'Success';
					foreach($res as $k=>$v)
					{
						$idList[$k]=$v;
					}
				}
				else
				{
					$statusCode = 1;
					$statusMessage = 'No records found.';
					$idList[0] = (object)array('id'=>'','name'=>'');
				}
			}
			else
			{
				$statusCode = 1;
				$statusMessage = 'Dealer or Employee does not exist';
				$idList[0] = (object)array('id'=>'','name'=>'');
			}
                     
                        
                        $response = array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'idList'=>$idList);
                        $this->sendResponse($response);
		}
                catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
            }
            
            //function to get the cities by rakesh on 06-12-2013
            /**
            * get Cities soap to rest conversion
            * @author Vyshnavi 23-12-2021 updated by soujanya on 10-7-2023
            * @params stateId 72 boxNumber 23120370003930
            * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'citiesList'=>$citiesList))
            */ 
            public function getCitiesRest_post()
            {
                try
                {
                //validations
                $validation_fields=['stateId'=>['isInteger|isRequired','State Id'],'boxNumber'=>['isString|isRequired','Box Number']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                                 // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                  //Validation end
                    $obj = new WsModel();
                    //Get the dealer_id and employee_id from auth token
                    $employeeId = $this->getEmployeeId();
                    $dealerId = $this->getDealerId();
                    $stateId = trim($this->payload->stateId);
                   
                    if($employeeId != 0 && $dealerId != 0)
                    {
                            $emp_id=0;
                            $box_number = trim($this->payload->boxNumber);
                            if($box_number!=''){
                                    $emp_id = $obj->getEmployeeId($box_number,$dealerId);
                            }
                            if(isset($employeeId) && ($employeeId != 0))
                            {
                                    $emp_id = $employeeId;
                            }

                            $res = $obj->getCities(trim($stateId),$dealerId,$emp_id);
                            $citiesList = array();
                            if(count($res)>0)
                            {
                                    $statusCode = 0;
                                    $statusMessage = 'Success';
                                    foreach($res as $k=>$v)
                                    {
                                            $citiesList[$k]=$v;
                                    }
                            }
                            else
                            {
                                    $statusCode = 1;
                                    $statusMessage = 'No records found.';
                                    $citiesList[0] = (object)array('location_id'=>'','location_name'=>'');
                            }
                    }
                    else
                    {
                            $statusCode = 1;
                            $statusMessage = 'Dealer or Employee does not exist';
                            $citiesList[0] = (object)array('location_id'=>'','location_name'=>'');
                    }
                

                    $response = (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'citiesList'=>$citiesList));
                    $this->sendResponse($response);
            }
            catch(Exception $e)
            {
                $this->error_res($e, 200);
            }
        }
            
        //function to get the districts by rakesh on 06-12-2013
        /**
        * get districts soap to rest conversion
        * @author Vyshnavi 24-12-2021 updated by soujanya on 10-7-2023
        * @params stateId 78
        * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'districtList'=>$districtList))
        */ 
        public function getdistrictsRest_post()
        {
            try
            {
                //validations
                $validation_fields=['stateId'=>['isInteger|isRequired','State Id']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                  // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                  //Validation end
                $obj = new WsModel();
                //Get the dealer_id and employee_id from auth token
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                $stateId=trim($this->payload->stateId);
              
                if($employeeId != 0 && $dealerId != 0)
                {
                        $res = $obj->getdistricts(trim($stateId));
                        $districtList = array();
                        if(count($res)>0)
                        {
                                $statusCode = 0;
                                $statusMessage = 'Success';
                                foreach($res as $k=>$v)
                                {
                                        $districtList[$k]=$v;
                                }
                        }
                        else
                        {
                                $statusCode = 1;
                                $statusMessage = 'No records found.';
                                $districtList[0] = (object)array('district_id'=>'','district_name'=>'');
                        }
                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = 'Dealer or Employee does not exist';
                        $districtList[0] = (object)array('district_id'=>'','district_name'=>'');
                }
                
                $response = (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'districtList'=>$districtList));
                $this->sendResponse($response);
            }  
            catch(Exception $e)
            {
                $this->error_res($e, 200);
            }
        }
        
        //function to get the states by rakesh on 06-12-2013
        /**
        * get States soap to rest conversion
        * @author Vyshnavi 24-12-2021
        * @params  countryCode US 
        * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'statesList'=>$statesList))
        */ 
        public function getStatesRest_post()
        {
            try{
                //validations
                $validation_fields=['countryCode'=>['isString|isRequired','Country Code']];
                $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                   // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                  //Validation end
                $obj = new WsModel();
                //Get the dealer_id and employee_id from auth token
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                
                //$countryCode=isset($this->payload->countryCode)?trim($this->payload->countryCode):0;
                $countryCode = trim($this->payload->countryCode);
                
                if($employeeId != 0 && $dealerId != 0)
                {
                        $res = $obj->getStates(trim($countryCode));

                        $statesList = array();
                        if(count($res)>0)
                        {
                                $statusCode = 0;
                                $statusMessage = 'Success';
                                foreach($res as $k=>$v)
                                {
                                        $statesList[$k]=$v;
                                }
                        }
                        else
                        {
                                $statusCode = 1;
                                $statusMessage = 'No records found.';
                                $statesList[0] = (object)array('id'=>'','name'=>'');
                        }
                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = 'Dealer or Employee does not exist';
                        $countriesList[0] = (object)array('id'=>'','name'=>'');
                }		
                
                $response = (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'statesList'=>$statesList));
                $this->sendResponse($response);
        }  
        catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
        }
                
                
        //function to get the countries by rakesh on 06-12-2013
        /**
        * get Countries soap to rest conversion
        * @author Vyshnavi 27-12-2021
        * @params  void
        * @return (array('status_code'=>$statusCode,'status_msg'=>$employeeId,'countriesList'=>$countriesList))
        */
        public function getCountriesRest_post()
        {
            try{
                $obj = new WsModel();
                //Get the dealer_id and employee_id from jwt token
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
               
                if($employeeId != 0 && $dealerId != 0)
                {
                        $res = $obj->getCountries();

                        $countriesList = array();
                        if(count($res)>0)
                        {
                                $statusCode = 0;
                                $statusMessage = 'Success';
                                foreach($res as $k=>$v)
                                {
                                        $countriesList[$k]=$v;
                                }
                        }
                        else
                        {
                                $statusCode = 1;
                                $statusMessage = 'No records found.';
                                $countriesList[0] = (object)array('iso'=>'','name'=>'');
                        }
                }
                else
                {
                        $statusCode = 1;
                        $statusMessage = 'Dealer or Employee does not exist';
                        $countriesList[0] = (object)array('iso'=>'','name'=>'');
                }
               
                $response = array('status_code'=>$statusCode,'status_msg'=>$employeeId,'countriesList'=>$countriesList);
                $this->sendResponse($response);
        }  
        catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
        }
                
        /**
        * Invoice Service soap to rest conversion
        * @author Vyshnavi 28-12-2021
        * @params dealer_id 1 customer_id 9 incomplete
        * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'invoice_details'=>$invoice_details))
        */
        public function InvoiceServiceRest_post()
        {
            try{
                //validations
                $validation_fields=['customer_id'=>['isInteger|isRequired','Customer Id'],'dealer_id'=>['isInteger|isRequired','Dealer Id']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                       // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                  //Validation end

                $obj = new WsModel();
                $employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
                $dealer_id=trim($this->payload->dealer_id);
                $customer_id=trim($this->payload->customer_id);
                $invoice_details=array();
                    write_to_file(" ============== Invoice_list_Service employeeId ============ ".json_encode($employeeId));
                    write_to_file(" ============== Invoice_list_Service dealer_id ============ ".json_encode($dealer_id));
                    write_to_file(" ============== Invoice_list_Service customer_id ============ ".json_encode($customer_id));
                    if($employeeId != 0 && $dealer_id != 0 && $customer_id != 0)
                    {
                            $response_details=$obj->Invoice_list_Service($dealer_id,$customer_id);
                            write_to_file(" ============== Invoice_list_Service query ============ ".$this->db->last_query());
                            /*$response_details= '[{"billing_id":"612","bill_date":"2024-06-27","due_date":"","base_price":"-241.94","quantity":"1","bill_no":"612","is_adhoc":"0","bill_month":"2024-06-01","dealer_id":"1","customer_id":"339","bill_amount":"250.00","setup_price":"0.00","tax_amount":"0.00","pending_amount":"0.00","total_amount":"250.00","total_paid_amount":"0.00","discount_amount":"0.00","product_id":"31","pname":"ProductAPP","customer_service_id":"565","serial_number":"SSD9156578028SAN","mac_vc_number":"SSD9156578028SAN","remarks":""}]';*/
                            //$response_details = json_decode($response_details);
                            //print_r($response_array);
                            if(count($response_details)>0)
                            {
                                    $statusCode = 0;
                                    $statusMessage = 'Success';
                                    foreach($response_details as $k=>$v)
                                    {
                                            $invoice_details[$k]=$v;
                                    }
                            }
                            else{
                                    $statusCode = 1;
                                    $statusMessage = 'Empty invoice list';
                            }
                    }
            else{
                    $statusCode = 1;
                    $statusMessage = 'Not a valid customer';
            }
               
		
                $response = array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'invoice_details'=>$invoice_details);
                $this->sendResponse($response);
        }
        catch(Exception $e)
                {
                    $this->error_res($e, 200);
                }
        }
                
                
       
        
        /**
        * Close Complaint soap to rest conversion
        * @author Vyshnavi 29-12-2021
        * @params complaintId 10 ticketNumber 21000029 comment rajesh test status CLOSED
        * @return (array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'invoice_details'=>$invoice_details))
        */
        public function closeComplaintRest_post()
	{
            try{
                $result= array();
                $statusCode = 1;
                //validations
                $validation_fields=['complaintId'=>['isInteger|isRequired','Complaint Id'],'assignedemp'=>['isString|isRequired','assigned emp'],'ticketNumber'=>['isString|isRequired','Ticket Number'],'comment'=>['isString|isRequired','Comment'],'status'=>['isString|isRequired','Status']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                //Validation end

                $this->load->model(array('Simplecomplaints_model'));
		$obj = new WsModel();
		$cf_objj = new CommonFunctions();
		//Get the dealer_id and employee_id from auth token
		$employeeId = $this->getEmployeeId();
                $dealerId = $this->getDealerId();
		$statusMessage = 'Failed to close';
               
		if($employeeId != 0 && $dealerId != 0)
		{
			$dbCategoryId=0;
			$parentCategoryName="";
			$categoryNameId=0;
			$dbCategoryName="";
			$dbSubcategoryName="";
                    $authToken = $this->getAuthToken();
                    $complaintId = trim($this->payload->complaintId);
                    $ticketNumber = trim($this->payload->ticketNumber);
                    $comment = trim($this->payload->comment);
                    $assigned_emp = isset($this->payload->assignedemp)?trim($this->payload->assignedemp):'';  
                    $status = isset($this->payload->status)?trim($this->payload->status):'';
					$ticketClouserData = $obj->getLovValue('TICKET_CLOUSER',$dealerId);
					$ticketClouser=isset($ticketClouserData) ? $ticketClouserData :0;
					// $category_id=0,$parentCategoryName="",$dbCategorychildId=0,$categoryName="",$SubCategory=""

					$closer_ticket_type_id = isset($this->payload->closer_ticket_type_id) ? trim($this->payload->closer_ticket_type_id) : 0;
					$closer_reason_id = isset($this->payload->closer_reason_id) ? trim($this->payload->closer_reason_id) : 0;
					$closer_subcategory_name = $closer_reason_id;

					if ($status == "RESOLVED") {
						if ($ticketClouser == 1) {
							$category_id = $closer_ticket_type_id;

							if ($category_id > 0) {
								$categoryIdResult = $this->Simplecomplaints_model->checkCategoryIdExistsOrNot($category_id, $dealer_id);
								$dbCategoryId = isset($categoryIdResult->category_id) ? $categoryIdResult->category_id : 0;
								$parentCategoryName = isset($categoryIdResult->category_name) ? $categoryIdResult->category_name : '';

								$categoryNameId = $closer_reason_id;

								if ($categoryNameId > 0) {
									$categoryNameResult = $this->Simplecomplaints_model->checkCategoryNameExistsOrNot($category_id, $categoryNameId, $dealer_id);
									$dbCategoryName = isset($categoryNameResult->category_name) ? $categoryNameResult->category_name : '';
									
									if (!empty($dbCategoryName)) {
										$subCategoryId = $closer_subcategory_name;

										if (!empty($subCategoryId)) {
											$subcategoryResult = $this->Simplecomplaints_model->checkSubCategoryIdExistsOrNot($category_id, $categoryNameId, $subCategoryId, $dealer_id);

											if ($subcategoryResult) {
												$dbSubcategoryName = isset($subcategoryResult->sub_category_name) ? $subcategoryResult->sub_category_name : '';
											}
										}
									}
								}
							}
						}
					}

					// ================================
		
                    
                    $requestId = 60;
                    $serverIp = $_SERVER['SERVER_ADDR'];
                    // $url = "http://".$serverIp."/developers/rakesh/ezybill/app/index.php/Simplecomplaints/WS_complaintUpdate";
                    // $url = "http://".$serverIp."/index.php/Simplecomplaints/WS_complaintUpdate";
                    $smsurl = $cf_objj->checkUrl()."Simplecomplaints/WS_complaintUpdate";
                    $data = array(
                            'authToken' => urlencode($authToken),
                            'complaintId' => urlencode($complaintId),
                            'ticketNumber' => urlencode($ticketNumber),
                            'comment' => urlencode($comment),
                            'status' => urlencode($status),
                            'employeeId' => urlencode($employeeId),
                            'dealerId' => urlencode($dealerId),
                            'requestId' => urlencode($requestId),
                            'requestServerIp' => urlencode($this->serverIp),
                        	'assigned_emp' => urlencode($assigned_emp)
                            //'imei' => urlencode($imei),
                    );			
                    //$response = trim($obj->callCurl($smsurl,$data));
                    //log_message("debug","=============response1===================".$response);
                    $login_user_type = "RESELLER";
                    $is_editable = 1;
                    $complaint_status = $this->Simplecomplaints_model->insertstatus($employeeId,$assigned_emp,$login_user_type,$is_editable,$dealerId,$this->payload,$from_mobileapp=1,
					$dbCategoryId,$parentCategoryName,$categoryNameId,$dbCategoryName,$dbSubcategoryName,$ticketClouser);
                    /*if(isset($response) && substr($response,0,2) == '61')
                    {
                            $statusCode = 0;
                            $statusMessage = substr($response,strpos($response,":")+1);
                            $result= array('status_code'=>$statusCode,'status_msg'=>$statusMessage);		
                    }
                    else if(isset($response) && substr($response,0,2) == '62')
                    {
                            $statusCode = 1;
                            $statusMessage = substr($response,strpos($response,":")+1);
                            $result= array('status_code'=>$statusCode,'status_msg'=>$statusMessage);		
                    }
                    else
                    {
                            $statusCode = 1;
                            $result= array('status_code'=>$statusCode,'status_msg'=>$statusMessage);				
                    }
                    */
                    $statusMessage = "Complaint update failed.";
                    if($complaint_status==1){
                        $statusCode = 0;
                        $statusMessage = "Success";

                    }
                    $result= array('status_code'=>$statusCode,'status_msg'=>$statusMessage);
		}
		else
		{
			$statusCode = 1;
		}
               
                //$response = (array('status_code'=>$statusCode,'status_msg'=>'Dealer or Employee does not exist.'));
                $this->sendResponse($result);
                	
	}
        catch(Exception $e)
            {
                $this->error_res($e, 200);
            }
        }
        
        /**
    * Create Complaint soap to rest conversion
    * @author Vyshnavi 3-Jan-2022
    * @params authToken complaint category error assignedTo
    * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessaget)
    */
    public function createComplaintRest_post()
    {
        try
        {
            //validations
            $validation_fields=['customerId'=>['isString|isRequired','Customer Id'],'complaint'=>['isString|isRequired','Complaint'],'category'=>['isInteger|isRequired','Category'],'error'=>['isString','Error'],'assignedTo'=>['isInteger','Assigned To']];
            $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }
            //Validation end

            //write_to_file('Request for complaint creation  : '.json_encode($customerInfo));
            $obj = new WsModel();
            $cf_objj = new CommonFunctions();
            $ticketNumber = 0;
            //Get the dealer_id and employee_id from auth token
            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();
            //$customer = $obj->getCustomerDetails($customerInfo->customerId,'','','',0,0,$dealerId,$employeeId);
            $customerId = isset($this->payload->customerId)?trim($this->payload->customerId):0;
            write_to_file('complaint creation  employeeId : '.$employeeId);
            write_to_file('complaint creation  dealerId : '.$dealerId);
            write_to_file('complaint creation  customerId : '.$customerId);
            
            if($customerId != 0 && $employeeId != 0 && $dealerId != 0)
            {
                $assignedTo = isset($this->payload->assignedTo)?trim($this->payload->assignedTo):$employeeId; 
                $authToken = $this->getAuthToken();
                $complaint = isset($this->payload->complaint)?trim($this->payload->complaint):'';
                $category = isset($this->payload->category)?trim($this->payload->category):0;
                $error = isset($this->payload->error)?trim($this->payload->error):'';
                $requestId = 50;
                /*
                $smsurl = $cf_objj->checkUrl()."Simplecomplaints/WS_createComplaint";
                $data = array(
                        'customerId' => urlencode($customerId),
                        'authToken' => urlencode($authToken),
                        'complaint' => urlencode($complaint),
                        'category' => urlencode($category),
                        'error' => urlencode($error),
                        'employeeId' => urlencode($employeeId),
                        'dealerId' => urlencode($dealerId),
                        'requestId' => urlencode($requestId),
                        'requestServerIp' => urlencode($this->serverIp),
                        'assignedTo'=> urlencode($assignedTo)
                        //'imei' => urlencode($imei),
                );	
                
                $response = trim($obj->callCurl($smsurl,$data));
                log_message("debug","=============response1===================".$response);
                write_to_file('Response for complaint creation  : '.json_encode($response));
                if(isset($response) && substr($response,0,2) == '51')
                {
                        $statusCode = 0;
                        // Added by Prasad ON 23-oct-20
                        $array_response = array();
                        $array_response = explode(':',$response);
                        $ticketNumber = isset($array_response[1])?$array_response[1]:'';
                        // echo "ticketNumber - ".$ticketNumber;exit;
                        // END, Added by Prasad ON 23-oct-20
                        $statusMessage = 'Complaint created successfully';
                        $result= array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'ticketNumber'=>$ticketNumber);	
                }
                else if(isset($response) && substr($response,0,2) == '52')
                {
                        $statusCode = 1;
                        $statusMessage = substr($response,strpos($response,":")+1);
                        $result= array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'ticketNumber'=>$ticketNumber);	
                }
                else
                {
                        $statusCode = 1;
                        $result= array('status_code'=>$statusCode,'status_msg'=>'Failed to create a complaint, something went wrong or due to path mismatch','ticketNumber'=>$ticketNumber);					
                }
                

                $data = array(
                        'customerId' => urlencode($customerId),
                        'authToken' => urlencode($authToken),
                        'complaint' => urlencode($complaint),
                        'category' => urlencode($category),
                        'sub_category' => urlencode($sub_category),
                        'error' => urlencode($error),
                        'employeeId' => urlencode($employeeId),
                        'dealerId' => urlencode($dealerId),
                        'requestId' => urlencode($requestId),
                        'requestServerIp' => urlencode($this->serverIp),
                        'assignedTo'=> urlencode($assignedTo)
                        //'imei' => urlencode($imei),
                    ); 
                    */
                    $this->load->library('Complaint_lib');
                    $complaint_lib = new Complaint_lib();
                    $selComplaintCategory=$category;
                    $cid=$customerId;
                    $complaint_creation_type= 2;
                    $assigneduserid=$assignedTo;
                    $msg=$complaint;
                    $dealer_id=$dealerId;
                    $reseller_id=$login_employee_id=$employeeId;
                    $is_from_selfcare='';

                $complaint_result = $complaint_lib->createComplaint($selComplaintCategory,$cid,$complaint_creation_type,$assigneduserid,$msg,$reseller_id,$dealer_id,$login_employee_id,$is_from_selfcare);
                //print_r($complaint_result);
                if(isset($complaint_result['status']) && $complaint_result['status']==1)
                {
                    $statusCode = 0;
                    $statusMessage = 'Success';
                    $ticketNumber = isset($complaint_result['tkt_number'])?$complaint_result['tkt_number']:"";
                    $result =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'ticketNumber'=>$ticketNumber);
                }else{
                    $statusCode = 1;
                    $statusMessage = 'Failed.';
                    $result =array('status_code'=>$statusCode, 'status_msg'=>$statusMessage);
                }
            }
            else
            {
                   $statusCode = 1;
                    $result =array('status_code'=>$statusCode,'status_msg'=>'Dealer or Employee does not exist.','ticketNumber'=>$ticketNumber);	
            }
       
        $this->sendResponse($result);
    }
    catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    }
    
    /*
     * Access control restriction - Srikanth
     */
     /**
    * get access control soap to rest conversion
    * @author Vyshnavi 4-Jan-2022
    * @params dealer_id 1
    * @return array('status_code'=>$statusCode,'status_msg'=>$statusMessage,'int_bulk_payment' => $int_bulk_payment,'invoice_page_access'=> $invoice_page_access,'payment_hist_page_access' => $payment_hist_page_access,'access_for_complaints'=>$access_for_complaints,'int_stb_activation'=>$int_stb_activation,'int_stb_deactivation'=>$int_stb_deactivation,'int_stb_reactivation'=>$int_stb_reactivation,)
    */
    public function getaccesscontrollRest_post(){
        try
        {
            $validation_fields=['employeeParentType'=>['isString','employee Parent Type'],'dealer_id'=>['isInteger|isRequired','dealer id'],'userstype'=>['isString|isRequired','users type'],'employeeParentId'=>['isInteger','employee Parent Id']];
        $employee_parent_type = isset($this->payload->employeeParentType)?$this->payload->employeeParentType:'';
        $dealer_id = isset($this->payload->dealer_id) ? $this->payload->dealer_id : 0;
         $user_type = isset($this->payload->userstype) ? $this->payload->userstype : '';
         $employee_parent_id = isset($this->payload->employeeParentId) ? $this->payload->employeeParentId : 0;
         
        $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
           // validation count
           if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

        $this->load->model(array('wsModel'));
        $obj = new wsModel();
        $int_bulk_payment=0;
        $int_stb_activation=0;
        $int_stb_deactivation=0;
        $int_stb_reactivation=0;
        
        //$dealer_id= ($this->post('dealer_id'))?$this->post('dealer_id'):0;
        //$authtoken= ($this->post('authtoken'))?$this->post('authtoken'):0;
        //$authtoken=trim($this->payload->authToken);
        //$dealer_id= trim($this->payload->dealer_id);
        //$employee_parent_type= trim($this->payload->employeeParentType);
//        $user_type= trim($this->payload->userstype);
//        $employee_parent_id= trim($this->payload->employeeParentId);
        
        //$employeeId = $obj->isValidPassToken(isset($authtoken)?trim($authtoken):'');
        $employeeId = $this->getEmployeeId();
       // $employee_parent_type = ($this->post('employeeParentType'))?$this->post('employeeParentType'):'';
       // $user_type = ($this->post('userstype'))?$this->post('userstype'):'';
       // $employee_parent_id = ($this->post('employeeParentId'))?$this->post('employeeParentId'):'';
        
        $report_access_for['reports_access'] = NULL;
        if($employeeId>0 && $dealer_id>0)
        {
            
            $report_access = $this->commonfunctions->setReportAuthenticationAccess($user_type, $employee_parent_type, $employeeId, $employee_parent_id,$dealer_id);
            if(count($report_access)>0){
                    $report_access_for['reports_access'] = (object)$report_access;
            }
            $report_invoice_access = (isset($report_access_for['reports_access']->INVOICES->view) && $report_access_for['reports_access']->INVOICES->view) ? 1 : 0;
            $report_payment_history = (isset($report_access_for['reports_access']->PAYMENT_HISTORY->view) && $report_access_for['reports_access']->PAYMENT_HISTORY->view) ? 1 : 0;
            $payment_transaction_report_access = (isset($report_access_for['reports_access']->PAYMENT_TRANSACTION_REPORT->view) && $report_access_for['reports_access']->PAYMENT_TRANSACTION_REPORT->view) ? 1 : 0;
            
            $access = new AccessModel();
            $this->aAccess=NULL;
            
            $accessModules = $access->get_user_Access($employeeId,$dealer_id);
            $modules = $access->get_modules($dealer_id);
            foreach($modules as $module){
                $this->amodules[$module->module_name] = $module->module_name;
            }
            $_SESSION['modules']=$this->amodules;
            if($employee_parent_type=="RESELLER" || $employee_parent_type=="DISTRIBUTOR" || $employee_parent_type=="SUBDISTRIBUTOR"){
                if(count($accessModules)==0){
                    $accessModules = $access->get_user_Access($employee_parent_id,$dealer_id);
                }
            }
            if(count($accessModules)==0){
                if($employee_parent_type=="RESELLER" || $employee_parent_type=="DISTRIBUTOR" || $employee_parent_type=="SUBDISTRIBUTOR"){
                   $accessModules = $access->getAccess($employee_parent_type, $dealer_id);
                }else{
                   //$accessModules = $this->commonfunctions->setAccessPrivilege();
                   $accessModules = $access->getAccess($user_type,$dealer_id);
                }
            }
            
            foreach($accessModules as $accessModule){
                $this->aAccess[$accessModule->module] = (object)array('create'=>$accessModule->create,'view'=>$accessModule->view,'edit'=>$accessModule->edit,'delete'=>$accessModule->delete,'report'=>$accessModule->report);
            }
            
            $accessPrivilage = array();
            if(count($this->aAccess)){
                $accessPrivilage = (object)$this->aAccess;
            }
            
            $access_for_customer_report = isset($accessPrivilage->CUSTOMERS) && ($accessPrivilage->CUSTOMERS->report) ? 1 : 0;
            $access_for_complaints = isset($accessPrivilage->COMPLAINTS) && ($accessPrivilage->COMPLAINTS->view || $accessPrivilage->COMPLAINTS->edit || $accessPrivilage->COMPLAINTS->delete )?1:0;
            
            
            $casAccess = array();
            $access_for['casAccess'] = NULL;
            //check whether the employee has personal authentication
            $casAccessResult = $access->getUserCasAccess($employeeId,$dealer_id);//employeeid,dealerid
            if($employee_parent_type=="RESELLER" || $employee_parent_type=="DISTRIBUTOR" || $employee_parent_type=="SUBDISTRIBUTOR"){
                //if that employee doesnt have personal authentication check for employee parent authentication
               if(count($casAccessResult)==0){
                    $casAccessResult = $access->getUserCasAccess($employee_parent_id,$dealer_id);
               }
            }

            //if that employee doesnt have personal authentication check for dealer authentication
            if(count($casAccessResult)==0){
                if($employee_parent_type=="RESELLER" || $employee_parent_type=="DISTRIBUTOR" || $employee_parent_type=="SUBDISTRIBUTOR"){                    
                    $casAccessResult = $access->getCasAccess($employee_parent_type,$dealer_id);
                 }else{
                    $casAccessResult = $access->getCasAccess($user_type,$dealer_id);
                 }
            }
            foreach($casAccessResult as $caccess){
                $casAccess[$caccess->stb_module] = $caccess->access;
            }
            if(count($casAccess)>0){
                $access_for['casAccess'] = (object)$casAccess;
            }
            $statusCode=0;
            $statusMessage='Success';
            $int_bulk_payment = (isset($access_for['casAccess']->BULK_PAYMENT) && ($access_for['casAccess']->BULK_PAYMENT==1)) ? $access_for['casAccess']->BULK_PAYMENT : 0;
            
            $int_stb_activation = (isset($access_for['casAccess']->STB_ACTIVATION) && ($access_for['casAccess']->STB_ACTIVATION==1)) ? $access_for['casAccess']->STB_ACTIVATION : 0;
            $int_stb_deactivation = (isset($access_for['casAccess']->STB_DEACTIVATION) && ($access_for['casAccess']->STB_DEACTIVATION==1)) ? $access_for['casAccess']->STB_DEACTIVATION : 0;
            $int_stb_reactivation = (isset($access_for['casAccess']->STB_REACTIVATION) && ($access_for['casAccess']->STB_REACTIVATION==1)) ? $access_for['casAccess']->STB_REACTIVATION : 0;
            
            //invoice page access
            $invoice_page_access = ($access_for_customer_report == 1 && $report_invoice_access == 1)? 1:0;
            
            //payment history page access
            $payment_hist_page_access = ($access_for_customer_report == 1 && $report_payment_history == 1)? 1:0;
            
        }
        else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
        $payment_transaction_report_access = 1;
        $response= array(
            'status_code'=>$statusCode, 
            'status_msg'=>$statusMessage,
            'int_bulk_payment' => $int_bulk_payment,
            'invoice_page_access'=> $invoice_page_access,
            'payment_hist_page_access' => $payment_hist_page_access,
            'access_for_complaints'=>$access_for_complaints,
            'int_stb_activation'=>$int_stb_activation,
            'int_stb_deactivation'=>$int_stb_deactivation,
            'int_stb_reactivation'=>$int_stb_reactivation,
            'int_payment_transaction_report_access' => $payment_transaction_report_access,
            );
        $this->sendResponse($response);
    }catch(Exception $e)
                {

                    $this->error_res($e, 200);
                }
    }
    
    /**
     * Encrypts the response and sends it back to client
     * @author PRASANNA 04-01-2022
     * @param array $response
     * @param int $http_status_code
     */
    private function sendResponse($response, $http_status_code=200){
        //print_r(json_encode($response));exit;
        write_to_file("--------------- Response ----------".json_encode($response));
        $encry_response = $this->encryption_lib->app_data_encryption($response);
        $this->response($encry_response, $http_status_code);	
        exit;
    }
    
    /*
     * get the lco share, mso share, total bill details by srikanth
     */
    /**
     * Encrypts the response and sends it back to client
     * @author Vyshnavi 7-01-2022
     * @param serial_number package_id bill_type customer_id employee_id
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,"basePrice"=>$getbasepriceamount);
     */
    public function getbilldetailsRest_post(){
        try{
        $validation_fields=['serial_number'=>['isString|isRequired','serial number'],'package_id'=>['isString|isRequired','package id'],'bill_type'=>['isInteger','bill type'],'customer_id'=>['isInteger|isRequired','customer Id'],'employee_id'=>['isInteger','Employee Id']];
        $serial_number = isset($this->payload->serial_number)?$this->payload->serial_number:'';
        $product_id = isset($this->payload->package_id) ? $this->payload->package_id : '';
        $customer_bill_type = isset($this->payload->bill_type) ? $this->payload->bill_type : 0;
        $customer_id = isset($this->payload->customer_id) ? $this->payload->customer_id : 0;
        $employeeId = isset($this->payload->employee_id)?$this->payload->employee_id:0;
        $chkemployeeid = $this->getEmployeeId();
        $dealerId = $this->getDealerId();
        $authToken = $this->getAuthToken();
        $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
        
        if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }
        $statusCode = 0;
        $statusMessage = "Success";
        /*
        $int_dealer_id = 1;
        $int_stock_id = 2;
        $int_backend_setup_id = 1;
        $int_customer_id = 213948;
        $int_reseller_id = 359;
        $selected_packages_array = array("188","305");
        $userType = "RESELLER";
        */
        $product_id_array = explode(",",$product_id);
        //$getbasepriceamount = $this->updated_get_base_price($dealerId,$employeeId,$customer_id,$product_id_array,$serial_number);
        $get_bill_data_array = $this->getPackageBillDetails($dealerId,$employeeId,$customer_id,$product_id_array,$serial_number);
        if(isset($get_bill_data_array['status_code']) && $get_bill_data_array['status_code'] == 0){
            $data = isset($get_bill_data_array['response_data']['data'])
            ? $get_bill_data_array['response_data']['data']
            : [];
            $mso_share_payble = 0.00;
            if (isset($data['mso_share']) && isset($data['ncf_data']['ncf_total_amount']) && isset($data['pending_msoshare'])) {
                $mso_share_payble = (float)$data['mso_share']
                                  + (float)$data['ncf_data']['ncf_total_amount']
                                  + (float)$data['pending_msoshare'];

                // Format with 2 digits after decimal using sprintf
                $mso_share_payble = sprintf('%.2f', $mso_share_payble); // result is a string
            }
            $statusCode = isset($get_bill_data_array['status_code']) ? (int)$get_bill_data_array['status_code'] : 1;
            $statusMessage = isset($get_bill_data_array['status_msg'])?$get_bill_data_array['status_msg']:"Get Bill Failed";
            // Build the output structure exactly as you specified
            $getbasepriceamount = [
                    'lco_share'                 => isset($data['lco_share']) ? (float)$data['lco_share'] : 0,
                    'mso_share'                 => isset($data['mso_share']) ? (float)$data['mso_share'] : 0,
                    'total_amount'              => isset($data['total_amount']) ? (float)$data['total_amount'] : 0,
                    'pend_mso_share'            => isset($data['pending_msoshare']) ? (float)$data['pending_msoshare'] : 0,
                    'tax_amount'                => isset($data['tax_amount']) ? (float)$data['tax_amount'] : 0,
                    'bill_amount'               => isset($data['bill_amount']) ? (float)$data['bill_amount'] : 0,

                    // Note: keeping your key names as-is (with "flaot_*")
                    'flaot_tax1'                => isset($data['mso_tax1']) ? (float)$data['mso_tax1'] : 0,
                    'flaot_tax2'                => isset($data['mso_tax2']) ? (float)$data['mso_tax2'] : 0,
                    'flaot_tax3'                => isset($data['mso_tax3']) ? (float)$data['mso_tax3'] : 0,
                    'flaot_tax4'                => isset($data['mso_tax4']) ? (float)$data['mso_tax4'] : 0,
                    'flaot_tax5'                => isset($data['mso_tax5']) ? (float)$data['mso_tax5'] : 0,
                    'flaot_tax6'                => isset($data['mso_tax6']) ? (float)$data['mso_tax6'] : 0,

                    'float_total_tax'           => isset($data['tax_amount']) ? (float)$data['tax_amount'] : 0,
                    'flaot_discount_amount'     => isset($data['discount_amount']) ? (float)$data['discount_amount'] : 0,
                    'flaot_amount_before_discount' => isset($data['base_price']) ? (float)$data['base_price'] : 0,

                    // NCF values – if you really want them 0, keep as 0; otherwise map from ncf_data
                    'ncf_total_amount'          => isset($data['ncf_data']['ncf_total_amount']) ? (float)$data['ncf_data']['ncf_total_amount'] : 0,
                    'encf_total_amount'         => 0,
                    'ncf_display_name'          => '',
                    'encf_display_name'         => '',
                    'mso_share_payble'          => $mso_share_payble
                ];
        }
        else{
            $statusCode = 1;
            $statusMessage = isset($get_bill_data_array['status_msg'])?$get_bill_data_array['status_msg']:"Get Bill Failed";
            $getbasepriceamount = array();
        }
        $response= array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,"basePrice"=>$getbasepriceamount);
        $this->sendResponse($response);
        }
    catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    }
    public function getPackageBillDetails($dealer_id,$reseller_id,$customer_id,$arr_products,$serial_number,$plugin_id=4)
    {
        log_message("debug","=========getPackageBillDetails_post============");
            
           try
           {
            $this->load->model(array('Validation_new_model','NewCustomerWithStbModel','Migration_model','WsModel','Process_Model','DasModel','LovModel','Productsmodel','Appsmodel'));
            $this->load->library(array('prepare_activation_postdata_lib','Special_charges_lib'));
            $employee_id = $reseller_id;
            $resonse_data = array();
            $arr_stb_details = array();
            $arr_ind_stb_details=array();
            $arr_plugin_details = array();
            $arr_cas_serial_number = array();
            $resultdata = array();
            $addnewboxtoexistingcustomer='';
            $arr_plugin_details = $this->Productsmodel->getplugins(0,1,0,'',1);
            $arr_plugin_names = array();
            if(!empty($arr_plugin_details)){
                // Loop through the fetched plugin data and dynamically populate the plugin names array
                foreach ($arr_plugin_details as $plugin) {
                    // You can adjust the key and value based on your data structure
                    $arr_plugin_names[$plugin->plugin_id] = $plugin->code;
                }
                $arr_plugin_names = array("0"=>'BUNDLE',"1"=>'ISP',"3"=>'OTT',"4"=>'CAS',"6"=>'GENERAL');
            }

            
            
           
            $Validation_new_model_obj = new Validation_new_model();

            $paid_at_mso = 0;
            str_to_file("packageids array==>".json_encode($arr_products));
            
            $lco_discount   = 0;
            $mso_share      = 0;
            $mso_tax1       = 0;
            $mso_tax2       = 0;
            $mso_tax3       = 0;
            $mso_tax4       = 0;
            $mso_tax5       = 0;
            $mso_tax6       = 0;
            $indv_mso_share = 0;
            $indv_mso_tax1  = 0;
            $indv_mso_tax2  = 0;
            $indv_mso_tax3  = 0;
            $indv_mso_tax4  = 0;
            $indv_mso_tax5  = 0;
            $indv_mso_tax6  = 0;
            $lco_share      = 0;
            $base_price     = 0;
            $bill_amount    = 0;
            $discount_amount= 0;
            $setup_price    = 0;
            $tax_amount     = 0;
            $tax1           = 0;
            $tax2           = 0;
            $tax3           = 0;
            $tax4           = 0;
            $tax5           = 0;
            $tax6           = 0;
            $total_amount   = 0;
            $original_total_amount = 0;
            $pending_msoshare = 0;
            $arr_products_calculated=array();
            $ncf_data_array = array(
                        "ncf_bill_amount"       =>  "0.00",
                        "ncf_total_tax_amount"  =>  "0.00",
                        "ncf_total_amount"      =>  "0.00",
                        "ncf_mso_share_amount"  =>  "0.00"
                    );
            // check if serial number is valid
            $arr_stb_details =  $Validation_new_model_obj->CheckSerialNumberDuplicate($serial_number);
            $array_dealer_setting = $this->LovModel->setDealerSettings($dealer_id);
            $array_dealer_setting = (array) $array_dealer_setting;
            //print_r($array_dealer_setting);exit;
            if( !empty($arr_stb_details)){
                $NewCustomerWithStbModel_obj = new NewCustomerWithStbModel();
                // serial number or box is valid
                $arr_ind_stb_details = $NewCustomerWithStbModel_obj->getSTBDetails('serial_number', $serial_number);
                //echo '<pre>';print_r($arr_ind_stb_details);exit;
                if(!empty($arr_ind_stb_details)){
                    $customer_id = isset($arr_ind_stb_details->customer_id)?$arr_ind_stb_details->customer_id:0;
                    $pending_msoshare = $this->Appsmodel->getMsoDue($customer_id);
                    $int_allow_mso_adj = $this->WsModel->getLovValue('BILL_EDIT_CUSTOMER_ADJUSTMENT', $dealer_id);
                    
                     if(isset($arr_products) && !empty($arr_products)) {
                    /*$arr_stb_details[$serial_number] = $arr_ind_stb_details;
                    $arr_stb_details[$serial_number]->plugin_id = $plugin_id;*/

                    //$array_dealer_setting = $this->setDealerSetting($this->LovModel->getDelearSetting($dealer_id));
                    //$array_dealer_setting = isset($_SESSION['dealer_setting']) ? ( array ) $_SESSION['dealer_setting'] : array();
                    $arr_product_details = array();  
                    $stock_id = isset($arr_stb_details->stock_id) ? $arr_stb_details->stock_id : 0;
                    $arr_stock_id[] = $stock_id;
                    // multi products
                    foreach ($arr_products as $key => $product_id) {
            
                        str_to_file("in loop product_id =>$product_id");
                                            
                        $arr_rule_set_info = $this->Migration_model->getRuleSetInfo($product_id, $dealer_id, $employee_id);
                        $rule_set_info = isset($arr_rule_set_info->rule_set_info)?$arr_rule_set_info->rule_set_info:array();
                        if(empty($rule_set_info)){
                            $rule_set_info = isset($arr_rule_set_info[0]->rule_set_info)?$arr_rule_set_info[0]->rule_set_info:array();
                        }
                        $extra_info = array('stock_id'=>$stock_id,'extra_quantity'=>0,'dealer_id'=>$dealer_id);
                        $product_data = $this->prepare_activation_postdata_lib->getProductProperties($rule_set_info, $extra_info);
                        $arr_product_details['cas_package'][$stock_id][$product_id] = $product_data;
                    }
                    $enum_add_on_after_base = isset($array_dealer_setting['ADDON_AFTER_BASEPACK']) ? $array_dealer_setting['ADDON_AFTER_BASEPACK'] : 0;
                    $int_end_time = isset($array_dealer_setting['SERVICE_ENDTIME'])?$array_dealer_setting['SERVICE_ENDTIME']:0;
                    $service_enddate_time = isset($array_dealer_setting['SERVICE_ENDDATE_TIME'])?$array_dealer_setting['SERVICE_ENDDATE_TIME']:'23:59:59';
                    $validation_operations = array();
                    if($customer_id > 0){
                        //Adding validations when assigning new box to existing customer
                        if($addnewboxtoexistingcustomer == 'addnewbox'){
                            $operation_name = 'activate_service_from_lco_portal';
                            $validation_operations[0]='existing_customer_validation';
                            $validation_operations[1]='new_box_validation';
                            $validation_operations[3]='existing_customer_package_validation';
                        } 
                        else{
                        // Add package to (Existing) stb
                            $operation_name = 'activate_service_from_lco_portal';
                            $validation_operations[0]='existing_customer_validation';
                            $validation_operations[1]='existing_box_validation';
                            $validation_operations[3]='existing_customer_package_validation';

                        }
                    }
                    else{
                        // New customer creation, add new stb to customer and add package to stb
                        $operation_name = 'activate_service_from_lco_portal';
                        // $validation_operations[0]='new_customer_validation';
                        $validation_operations[1]='new_box_validation';
                        $validation_operations[3]='new_customer_package_validation';
                    }
                    $int_operation_id= $this->Process_Model->getoperation_id($operation_name,$dealer_id);

                    $extra_parameters_postdata = [
                    'array_dealer_setting'=>$array_dealer_setting,
                    'enum_add_on_after_base'=>$enum_add_on_after_base,
                    'double_stb_discount'=>0,
                    'reseller_id' => $reseller_id,
                    'int_customer_id' => $customer_id,
                    'end_time' => $int_end_time,
                    'service_enddate_time'=>$service_enddate_time 

                    ];

                    $arr_final_result = $this->prepare_activation_postdata_lib->prepareDataForActivation($dealer_id, $arr_product_details, $extra_parameters_postdata);
                    $arr_plugin_wise_product_info = (isset($arr_final_result['arr_plugin_wise_product_info']) && count($arr_final_result['arr_plugin_wise_product_info'])>0)?$arr_final_result['arr_plugin_wise_product_info']:[];
                    $arr_stb_details = (isset($arr_final_result['arr_stb_details']) && count($arr_final_result['arr_stb_details'])>0 ) ? $arr_final_result['arr_stb_details']:[];

                    if(4 == $plugin_id)
                    {   // CAS
                        // New box  
                      
                        if($serial_number!='')
                        {
                            $arr_cas_serial_number[] = $serial_number;
                            if($customer_id>0){
                                //new box to existing customer
                                if($addnewboxtoexistingcustomer == 'addnewbox'){
                                    $arr_plugin_details['CAS']['box_selection']= 'new'; 
                                    $arr_plugin_details['CAS']['arr_cas_serial_number']= $arr_cas_serial_number;
                                }
                                else{
                                    //Activationg service on existing box
                                    $arr_plugin_details['CAS']['box_selection']= 'existing';    
                                    $arr_plugin_details['CAS']['arr_cas_stock_id']= $arr_stock_id;                       
                                    $arr_plugin_details['CAS']['arr_cas_serial_number']= $arr_cas_serial_number;
                                }
                            }
                            else{
                                //new customer creation
                                $arr_plugin_details['CAS']['box_selection']= 'new'; 
                                $arr_plugin_details['CAS']['arr_cas_stock_id']= $arr_stock_id;                     
                                $arr_plugin_details['CAS']['arr_cas_serial_number']= $arr_cas_serial_number;
                            }
                            //start - plugin details array
                           
                        //end - plugin details array
                        }                
                    }
                    $int_enable_prorata_discount = isset($array_dealer_setting['ENABLE_PRORATA_DISCOUNT'])?$array_dealer_setting['ENABLE_PRORATA_DISCOUNT']:0;
                     $extra_parameters = [
                    'enum_add_on_after_base'=>$enum_add_on_after_base,
                    'double_stb_discount'=>0,
                    'reseller_id' => $reseller_id,
                    'int_customer_id' => $customer_id,
                    'end_time' => $int_end_time,
                    'dealer_id' => $dealer_id,
                    'login_employee_id' => $reseller_id,
                    'dealer_setting' => $array_dealer_setting,
                    'validation_operation_names'=>$validation_operations,
                    'int_operation_id'=>$int_operation_id,
                    'int_enable_prorata_discount'=>$int_enable_prorata_discount,
                    'is_new_customer'=>0,
                    'paid_at_mso'=>$paid_at_mso
                    ];
                    
                    if(isset($arr_plugin_wise_product_info['CAS']) && count($arr_plugin_wise_product_info['CAS'])>0){
                        $extra_parameters['arr_special_charges'] = ['INSTALLATION_CHARGES', 'NCF_ENCF'];
                        $extra_parameters['ncf_bill_type'] = 1;
                    }
                    $customer_details_array = array('reseller_id'=>$reseller_id,'customer_id'=>$customer_id);
                    $data_for_operation = array(
                    'arr_customer_details' => $customer_details_array,
                    'arr_plugin_details' => $arr_plugin_details,
                    'extra_parameters' => $extra_parameters,
                    'arr_box_details' => $arr_stb_details,                    
                    'arr_act_package_details'=>$arr_plugin_wise_product_info,
                    STATUS=>SUCCESS,
                    ERR_CODE=>'SUC_0000',
                    ERR_MSG=>'Success'
                    ); 
                    
                    $extra_parameters['int_estimation'] = 1;
                    $ncfEncfDetails = $this->special_charges_lib->getNcfEncfChargeDetails($dealer_id, $dealer_id, $customer_id, $employee_id, $arr_plugin_wise_product_info, $arr_deact_package_details=array(), $extra_parameters);
                    $ncf_bill_amount = isset($ncfEncfDetails['NCF'][$serial_number]['bill_amount'])?$ncfEncfDetails['NCF'][$serial_number]['bill_amount']:"0.00";
                    $ncf_total_tax_amount = isset($ncfEncfDetails['NCF'][$serial_number]['tax_amount'])?$ncfEncfDetails['NCF'][$serial_number]['tax_amount']:"0.00";
                    $ncf_total_amount = isset($ncfEncfDetails['NCF'][$serial_number]['total_amount'])?$ncfEncfDetails['NCF'][$serial_number]['total_amount']:"0.00";
                    $ncf_mso_share_amount = isset($ncfEncfDetails['NCF'][$serial_number]['mso_share'])?$ncfEncfDetails['NCF'][$serial_number]['mso_share']:"0.00";
                    $ncf_data_array = array(
                        "ncf_bill_amount"       =>  $ncf_bill_amount,
                        "ncf_total_tax_amount"  =>  $ncf_total_tax_amount,
                        "ncf_total_amount"      =>  $ncf_total_amount,
                        "ncf_mso_share_amount"  =>  $ncf_mso_share_amount
                    );
                    
                    if(count($data_for_operation)>0){
                        $this->load->library('Workflow_lib');
                        $int_operation_id = $data_for_operation['extra_parameters']['int_operation_id'];
                        $activity_id = 7; 
                        $this->workflow_lib->executeWorkFlow($int_operation_id, $activity_id, $data_for_operation);
                        
                        if(isset($data_for_operation[STATUS]) && SUCCESS==$data_for_operation[STATUS])
                        {
                            $status_code = 1;
                            $status_message="Success";
                            //$plugin_id = isset($data_for_operation['plugin_id'])?$data_for_operation['plugin_id']:4;
                            if($plugin_id == 4 )
                            {
                                    
                                $special_charges_result = isset($data_for_operation['arr_special_ncf_encf'])?$data_for_operation['arr_special_ncf_encf']:array();
                                $result['special_charges_msg'] = isset($special_charges_result)?$special_charges_result:array();
                                $resultdata_opr = $data_for_operation['arr_act_package_details'][$arr_plugin_names[$plugin_id]];
                                
                                foreach($resultdata_opr as $key=>$res)
                                {
                                    
                                    foreach ($res as $product_data) 
                                    {
                                        
                                        
                                       // $resultdata['special_charges_msg']['serial_number'] =$product_data['serial_number']; 
                                        //$resultdata['msg'] = ($product_data['product_bill_data']);
                                        if(isset($product_data['product_bill_data'])){
                                            if(!(in_array($product_data['product_id'], $arr_products_calculated))){
                                                str_to_file("msoshare $key before#".$mso_share);
                                                
                                                $lco_discount     += isset($product_data['product_bill_data']['lco_discount']) ? $product_data['product_bill_data']['lco_discount'] : 0;
                                                $mso_share        += isset($product_data['product_bill_data']['mso_share']) ? $product_data['product_bill_data']['mso_share'] : 0;
                                                str_to_file("msoshare $key after#".$mso_share);
                                                
                                                $mso_tax1         += isset($product_data['product_bill_data']['mso_tax1']) ? $product_data['product_bill_data']['mso_tax1'] : 0;
                                                $mso_tax2         += isset($product_data['product_bill_data']['mso_tax2']) ? $product_data['product_bill_data']['mso_tax2'] : 0;
                                                $mso_tax3         += isset($product_data['product_bill_data']['mso_tax3']) ? $product_data['product_bill_data']['mso_tax3'] : 0;
                                                $mso_tax4         += isset($product_data['product_bill_data']['mso_tax4']) ? $product_data['product_bill_data']['mso_tax4'] : 0;
                                                $mso_tax5         += isset($product_data['product_bill_data']['mso_tax5']) ? $product_data['product_bill_data']['mso_tax5'] : 0;
                                                $mso_tax6         += isset($product_data['product_bill_data']['mso_tax6']) ? $product_data['product_bill_data']['mso_tax6'] : 0;
                                        
                                                $indv_mso_share   += isset($product_data['product_bill_data']['indv_mso_share']) ? $product_data['product_bill_data']['indv_mso_share'] : 0;
                                                $indv_mso_tax1    += isset($product_data['product_bill_data']['indv_mso_tax1']) ? $product_data['product_bill_data']['indv_mso_tax1'] : 0;
                                                $indv_mso_tax2    += isset($product_data['product_bill_data']['indv_mso_tax2']) ? $product_data['product_bill_data']['indv_mso_tax2'] : 0;
                                                $indv_mso_tax3    += isset($product_data['product_bill_data']['indv_mso_tax3']) ? $product_data['product_bill_data']['indv_mso_tax3'] : 0;
                                                $indv_mso_tax4    += isset($product_data['product_bill_data']['indv_mso_tax4']) ? $product_data['product_bill_data']['indv_mso_tax4'] : 0;
                                                $indv_mso_tax5    += isset($product_data['product_bill_data']['indv_mso_tax5']) ? $product_data['product_bill_data']['indv_mso_tax5'] : 0;
                                                $indv_mso_tax6    += isset($product_data['product_bill_data']['indv_mso_tax6']) ? $product_data['product_bill_data']['indv_mso_tax6'] : 0;
                                        
                                                $lco_share        += isset($product_data['product_bill_data']['lco_share']) ? $product_data['product_bill_data']['lco_share'] : 0;
                                                $base_price       += isset($product_data['product_bill_data']['base_price']) ? $product_data['product_bill_data']['base_price'] : 0;
                                                $bill_amount      += isset($product_data['product_bill_data']['bill_amount']) ? $product_data['product_bill_data']['bill_amount'] : 0;
                                                $discount_amount  += isset($product_data['product_bill_data']['discount_amount']) ? $product_data['product_bill_data']['discount_amount'] : 0;
                                                $total_amount     += isset($product_data['product_bill_data']['total_amount']) ? $product_data['product_bill_data']['total_amount'] : 0;
                                                $original_total_amount += isset($product_data['product_bill_data']['original_total_amount']) ? $product_data['product_bill_data']['original_total_amount'] : 0;
                                                $tax_amount       += isset($product_data['product_bill_data']['tax_amount']) ? $product_data['product_bill_data']['tax_amount'] : 0;
                                        
                                                $arr_products_calculated[] = $product_data['product_id'];
                                                $status_code = 0;
                                            }
                                        }
                                        else{
                                            $status_code = 1;
                                            $status_message = "Bill details not found for the packages.";
                                        }
                                    }
                                }   
                                if(isset($product_data['product_bill_data'])){

                                    $resultdata['lco_discount'] = $lco_discount;
                                    $resultdata['mso_share'] = $mso_share;
                                    $resultdata['mso_tax1'] = $mso_tax1;
                                    $resultdata['mso_tax2'] = $mso_tax2;
                                    $resultdata['mso_tax3'] = $mso_tax3;
                                    $resultdata['mso_tax4'] = $mso_tax4;
                                    $resultdata['mso_tax5'] = $mso_tax5;
                                    $resultdata['mso_tax6'] = $mso_tax6;
                                    $resultdata['indv_mso_share'] = $indv_mso_share;
                                    $resultdata['indv_mso_tax1'] = $indv_mso_tax1;
                                    $resultdata['indv_mso_tax2'] = $indv_mso_tax2;
                                    $resultdata['indv_mso_tax3'] = $indv_mso_tax3;
                                    $resultdata['indv_mso_tax4'] = $indv_mso_tax4;
                                    $resultdata['indv_mso_tax5'] = $indv_mso_tax5;
                                    $resultdata['indv_mso_tax6'] = $indv_mso_tax6;
                                    $resultdata['lco_share'] = $lco_share;
                                    $resultdata['tax_amount'] = $tax_amount;
                                    $resultdata['base_price'] = $base_price;
                                    $resultdata['bill_amount'] = $bill_amount;
                                    $resultdata['discount_amount'] = $discount_amount;
                                    $resultdata['total_amount'] = $total_amount;
                                    $resultdata['original_total_amount'] = $original_total_amount;
                                    $resultdata['ncf_data'] = $ncf_data_array;
                                    $resultdata['pending_msoshare'] = $pending_msoshare;

                                }

                            }
                        }
                        else
                        {
                            $status_code = 1;
                            $status_message = isset($data_for_operation[ERR_MSG])?$data_for_operation[ERR_MSG]:'Could not fetch billing details';
                        }
                    }
                //   }
                 }
                 else{
                    $status_code = 1;
                    $status_message = "There are no package id's.";
                 }
                    
                }
                else{
                    $status_code = 1;
                    $status_message = "Stock does not exists for Serial Number.";
                }
            }
            else{
                $status_code = 1;
                $status_message = "Serial Number is invalid.";
                //$status_message = 'ERR_BOX_0061';
            }  
            $response =array('status_code'=>$status_code, 'status_msg'=>$status_message,"response_data"=>['data'=>$resultdata]);
            return $response;
        } 
        catch(Exception $e)
        {      
            $resultdata = array();  
            $response =array('status_code'=>1, 'status_msg'=>"Exception Failed".$e->getMessage(),"response_data"=>['data'=>$resultdata]);
            return $response;
        }   
    }
    public function updated_get_base_price($int_dealer_id,$int_reseller_id,$int_customer_id,$selected_packages_array,$serial_number,$userType="RESELLER"){
        $this->load->library(array('service_extension_lib','customer_billing_lib'));
        $this->load->model(array('NewCustomerWithStbModel','wsModel'));

        //$int_dealer_id = 1;
        //$int_stock_id = 2;
        //$int_backend_setup_id = 1;
        //$int_customer_id = 213948;
        //$int_reseller_id = 359;
        //$selected_packages_array = array("188","305");
        //$userType = "RESELLER";

        write_to_file("-------------- int_customer_id -----------".json_encode($int_customer_id));
        write_to_file("-------------- int_reseller_id -----------".json_encode($int_reseller_id));
        write_to_file("-------------- selected_packages_array -----------".json_encode($selected_packages_array));

        $stokDetails = $this->wsModel->stockDetails($serial_number);
        if (!empty($stokDetails)) {
            $int_stock_id = $stokDetails->stock_id;
            $int_backend_setup_id = $stokDetails->backend_setup_id;
        }
        write_to_file("-------------- int_stock_id -----------".json_encode($int_stock_id));
        write_to_file("-------------- int_backend_setup_id -----------".json_encode($int_backend_setup_id));
        $bill_period_start = date('Y-m-d');
        $service_end_date=date('Y-m-d', strtotime($bill_period_start . ' -1 day'));
        $int_plugin_id = 4;
        $str_active_product_list="";
        $stb_type_id = "";

        $lco_share = 0;
        $mso_share = 0;
        $total_amount = 0;
        $tax_amount = 0;
        $flaot_tax1 = 0;
        $flaot_tax2 = 0;
        $flaot_tax3 = 0;
        $flaot_tax4 = 0;
        $flaot_tax5 = 0;
        $flaot_tax6 = 0;
        $flaot_discount_amount = 0;
        $bill_amount = 0;

        $flaot_amount_before_discount = 0;
        $pend_mso_share = 0;
        $ncf_total_amount = 0;
        $encf_total_amount = 0;
        $ncf_display_name = "";
        $encf_display_name = "";

        foreach($selected_packages_array as $int_product_id){
            //print_r($int_product_id);
            write_to_file("-------------- int_product_id -----------".json_encode($int_product_id));
            $package_data_array = $this->NewCustomerWithStbModel->get_customerservice_products($int_customer_id, $int_backend_setup_id, $str_active_product_list, $int_dealer_id, $stb_type_id, $int_stock_id, $userType, $setting_value=1, $int_reseller_id, $sort_order_val=1, $flag=0,$plugin_id=4,$product_date='',$default_verification=0,$int_product_id);
            write_to_file("-------------- package_data_array query -----------".$this->db->last_query());
            write_to_file("-------------- package_data_array -----------".json_encode($package_data_array));
            $int_billing_schedule = 0;
            $int_service_duration_id = 0;
            $int_quantity = 0;
            $bill_period_end = "";
            //print_r($package_data_array);exit;
            if(!empty($package_data_array)){
                foreach ($package_data_array as $key => $value) {
                    $ruleset_data=json_decode($value->rule_set_info,true);
                    $product_data_array[$key] = array("product_id"=>$value->product_id,"name"=>$value->pname,"bill_type_attributes"=>$ruleset_data['RuleSetType'][0]['bill_type'][0]['bill_type_attributes'],"billing_schedule_attributes"=>$ruleset_data['RuleSetType'][1]['billing_schedule'][0]['billing_schedule_attributes'],"service_duration_attributes"=>$ruleset_data['RuleSetType'][2]['service_duration'][0]['service_duration_attributes']);
                }
                //print_r(json_encode($product_data_array));exit;
                $product = $product_data_array[0];
                $billingSchedule = $product['billing_schedule_attributes'][0];
                $serviceDuration = $product['service_duration_attributes'][0];
                $ruleSetTransAttrib = $serviceDuration['RuleSetTransAttrib'][0];
                $int_billing_schedule = $billingSchedule['billing_schedule_id'];;
                $int_service_duration_id = $serviceDuration['customer_service_duration_id'];
                $int_quantity = $ruleSetTransAttrib['quantity'];
            }

            $int_validity = 1;
            $int_validity_days = 1;
            $int_quantity = 1;
            $array_extension_date_params = array("int_service_type"=>$int_service_duration_id,"int_validity_days"=>$int_validity_days,"date_service_enddate"=>$service_end_date,"int_quantity"=>$int_quantity);
            $end_date_for_extension = $this->service_extension_lib->calculateServiceExtensionDate($array_extension_date_params);
            write_to_file("-------------- end_date_for_extension -----------".json_encode($end_date_for_extension));
            if(!empty($end_date_for_extension)){
                if($end_date_for_extension['status'] == 1 && $end_date_for_extension['msg'] == "Success" && isset($end_date_for_extension['extension_date']) && $end_date_for_extension['extension_date'] != ""){
                    $bill_period_end = $end_date_for_extension['extension_date'];
                }
            }

            //print_r("----- bill_period_start -------".$bill_period_start);
            //print_r("----- bill_period_end -------".$bill_period_end);
            write_to_file("-------------- bill_period_start -----------".json_encode($bill_period_start));
            write_to_file("-------------- bill_period_end -----------".json_encode($bill_period_end));
            $extra_billing_details=['int_stock_id'=>$int_stock_id,'int_customer_id'=>$int_customer_id, 'int_reseller_id'=>$int_reseller_id,'from_lco_mobile_app'=>1];
            $result = $this->customer_billing_lib->calculateCustomerOnetimeAndRecurringBilling($int_dealer_id, $int_plugin_id, $int_product_id, $int_billing_schedule, $bill_period_start, $bill_period_end, $int_service_duration_id, $int_quantity , $int_validity,$extra_billing_details);
            write_to_file("-------------- calculateCustomerOnetimeAndRecurringBilling -----------".json_encode($result));
            //print_r(json_encode($result));exit;
            //print_r("ended....");
            $lco_share = $lco_share + (isset($result['lco_share'])?$result['lco_share']:0);
            $mso_share = $mso_share + (isset($result['mso_share'])?$result['mso_share']:0);
            $total_amount = $total_amount + (isset($result['total_amount'])?$result['total_amount']:0);
            $tax_amount = $tax_amount + (isset($result['tax_amount'])?$result['tax_amount']:0);
            $bill_amount = $bill_amount + (isset($result['bill_amount'])?$result['bill_amount']:0);
            $flaot_tax1 = $flaot_tax1 + (isset($result['tax1'])?$result['tax1']:0);
            $flaot_tax2 = $flaot_tax2 + (isset($result['tax2'])?$result['tax2']:0);
            $flaot_tax3 = $flaot_tax3 + (isset($result['tax3'])?$result['tax3']:0);
            $flaot_tax4 = $flaot_tax4 + (isset($result['tax4'])?$result['tax4']:0);
            $flaot_tax5 = $flaot_tax5 + (isset($result['tax5'])?$result['tax5']:0);
            $flaot_tax6 = $flaot_tax6 + (isset($result['tax6'])?$result['tax6']:0);
            $flaot_discount_amount = $flaot_discount_amount + (isset($result['discount_amount'])?$result['discount_amount']:0);
        }
        $float_total_tax = $flaot_tax1 + $flaot_tax2 + $flaot_tax3 + $flaot_tax4 + $flaot_tax5 + $flaot_tax6;

        $getbasepriceamount = array(
                'lco_share'=>$lco_share,'mso_share'=>$mso_share,'total_amount'=>$total_amount,'pend_mso_share'=>$pend_mso_share,'tax_amount'=>$tax_amount,
                'bill_amount'=>$bill_amount,'flaot_tax1'=>$flaot_tax1,'flaot_tax2'=>$flaot_tax2,'flaot_tax3'=>$flaot_tax3,'flaot_tax4'=>$flaot_tax4,
                'flaot_tax5'=>$flaot_tax5,'flaot_tax6'=>$flaot_tax6,'float_total_tax'=>$float_total_tax,'flaot_discount_amount'=>$flaot_discount_amount,
                'flaot_amount_before_discount'=>$flaot_amount_before_discount,'ncf_total_amount'=>$ncf_total_amount,'encf_total_amount'=>$encf_total_amount,
                'ncf_display_name'=>$ncf_display_name,'encf_display_name'=>$encf_display_name
        );
        return $getbasepriceamount;
    }
    
    /**
     * Encrypts the response and sends it back to client
     * @author Vyshnavi 13-01-2022
     * @param start_date 2020-09-23 end_date 2020-09-23 dealer_id 1
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,"getLcoWalletReport"=>$getLcoWalletReport)
     */
    public function getlcowalletRest_post()
    {
        try{
                $str_startdate = isset($this->payload->start_date) ? $this->payload->start_date: date('Y-m-d');
                $str_enddate = isset($this->payload->end_date) ? $this->payload->end_date: date('Y-m-d');
                $dealer_id= isset($this->payload->dealer_id) ? $this->payload->dealer_id: 0;
                $validation_fields=['start_date'=>['checkValidDate|isRequired','Start Date'],'end_date'=>['checkValidDate|isRequired','End Date'], 'dealer_id'=>['isInteger|isRequired','Dealer Id']];
                $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                 // validation count
                if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }

                //$authToken = $this->getAuthToken();
                $employeeId = $this->getEmployeeId();
                $this->load->model(array('EmployeeModel','WsModel'));
                $statusCode=1;
                $statusMessage = '';
                $getLcoWalletReport=array();
                if($employeeId>0 && $dealer_id>0)
                {
                    $getLcoWalletReport = $this->WsModel->getlcoWalletReportSelfcare($str_startdate,$str_enddate,$dealer_id,$employeeId);
                    //echo $this->db->last_query(); exit;
                    if(!empty($getLcoWalletReport))
                    {
                        $statusCode = 0;
                        $statusMessage = 'Success';
                    }
                    else
                    {
                        $statusCode = 1;
                        $statusMessage = 'No records found.';
                    }
                }
                else
                {
                    $statusCode = 1;
                    $statusMessage = 'Authentication Failed';
                }
               $response=array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,"getLcoWalletReport"=>$getLcoWalletReport);
               $this->sendResponse($response);
         }catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    }
    
    /**
     * Payment Transactions logs
     * @author Rajesh 18-Jan-2022
     * @params {"dealer_id":1}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'paymentresult' => $arr_paymentresult)
     */
    public function pgTransactionLogs_post(){
        try {
        //validations
        $dealer_id= isset($this->payload->dealer_id) ? $this->payload->dealer_id: 0;
        $payment_status= isset($this->payload->payment_status) ? $this->payload->payment_status:0;
        write_to_file(" =================== pgTransactionLogs payment_status ================ ".json_encode($payment_status));
        //$startdate = isset($this->payload->start_date) ? $this->payload->start_date: date('Y-m-d');
        $end_date = isset($this->payload->end_date) ? $this->payload->end_date: date('Y-m-d');
        $validation_fields=['payment_status'=>['isInteger','payment status'],'start_date'=>['checkValidDate','Start Date'],'end_date'=>['checkValidDate','End Date'],'dealer_id'=>['isInteger','dealer id']];
        log_message('debug', '====paymentstatus====='.$payment_status);
        log_message('debug', '====datatype====='.gettype($payment_status));
        $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
            // validation count
            if(count($validation_response_array) > 0){
                // validation error
                $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                $response = array(  'status_code'=>$statusCode,
                                    'status_msg'=>$statusMessage
                                );
                $this->sendResponse($response);
            }

        $this->load->model(array('wsModel','reportsModel'));
        $obj = new wsModel();
        $reports=new reportsmodel();
        $statusCode=1;
        $statusMessage = '';
        $authToken = $this->getAuthToken();
        $employeeId = $this->getEmployeeId();
        $start_date= date('Y-m-d', strtotime('-3month'));
//        $end_date = date('Y-m-d');


        $arr_paymentresult=array();
        if($employeeId>0 && $dealer_id>0){
            //get the payment result
            $arr_paymentresult = $reports->getPaymentTransactionresult(-1,'','','',1,$start_date,$end_date,0,0,$select_statement='',$csv=0,$dealer_id,$employeeId,'',0,-1,-1,$payment_status,$from_mobileapp=1);
            write_to_file(" ============= getPaymentTransactionresult ======= ".$this->db->last_query());					
            //echo "<pre>";print_r($paymentresult);
            //echo "<pre>";print_r($this->db->last_query());exit;
            //echo $this->db->last_query(); exit;
            if(count($arr_paymentresult)>0)
            {
                $statusCode = 0;
                $statusMessage = 'Success';
            }else{
                $statusMessage = 'No List';
            }
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'paymentresult' => $arr_paymentresult);
        $this->sendResponse($response);
         }catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    } 
    
    /**
     * get total complaints list
     * @author Rajesh 18-Jan-2022
     * @params {"dealer_id":1}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'getServiceEmployeeList' => $arr_getServiceEmployeeList)
     */
    public function getServiceEmployeeList_post(){
        try {
        $dealer_id= isset($this->payload->dealer_id) ? $this->payload->dealer_id: 0;
        $validation_fields=['dealer_id'=>['isInteger|isRequired','dealer id']];
        $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);

        if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

        $this->load->model(array('wsModel', 'EmployeeModel'));
        $obj = new wsModel();
        $objComplaints = new simplecomplaints_model();
        $statusCode=1;
        $statusMessage = '';
        
        $authToken = $this->getAuthToken();
        $employeeId = $this->getEmployeeId();
        $arr_getServiceEmployeeList=array();
        if($employeeId>0 && $dealer_id>0){
            //get the complaints list
            $arr_getServiceEmployeeList = $this->EmployeeModel->getServiceEmpList($dealer_id,$employeeId);					
            
            if(count($arr_getServiceEmployeeList)>0)
            {
                $statusCode = 0;
                $statusMessage = 'Success';
            }else{
                $statusMessage = 'No Services Employees.';
            }
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'getServiceEmployeeList' => $arr_getServiceEmployeeList);
        $this->sendResponse($response);
         }catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    } 
    
    
    /**
     * get total complaints list
     * @author Rajesh 18-Jan-2022
     * @params {"dealer_id":1}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'gettotalcomplaintslist' => $arr_getComplaintsList)
     */
    public function gettotalcomplaintslist_post(){
        try {
        $this->load->model(array('wsModel'));
        $obj = new wsModel();
        $objComplaints = new simplecomplaints_model();
        $statusCode=1;
        $statusMessage = '';
        $dealer_id= isset($this->payload->dealer_id) ? $this->payload->dealer_id: 0;
        $authToken = $this->getAuthToken();
        $employeeId = $this->getEmployeeId();
        $user_data = $this->WsModel->getUserDetails($employeeId,$dealer_id);
        $parent_type = $user_data->employee_parent_type;
        $user_type =$user_data->users_type;
        if(($user_data->users_type=='EMPLOYEE') && ($user_data->employee_parent_type=='DISTRIBUTOR' || $user_data->employee_parent_type=='SUBDISTRIBUTOR' ||  $user_data->employee_parent_type=='RESELLER')){
            $user_type = $user_data->employee_parent_type;
            $employeeId = isset($user_data->parent_id)?$user_data->parent_id:$employeeId;
        }
        $arr_getComplaintsList=array();
        $totalComplaints = 0;
        if ($user_type == 'RESELLER' || ($user_type == 'EMPLOYEE' && $parent_type == 'RESELLER')) {
        $this->load->library('dashboard/charts/DashboardData');
        $DashboardData = new DashboardData();
        $getDashboardItemsLibrary = $DashboardData->getDashboardItems($dealer_id, $employeeId,$user_type,$employeeId);
        // print_r($getDashboardItemsLibrary);die;
        if (!empty($getDashboardItemsLibrary)) {
                foreach ($getDashboardItemsLibrary as $dashboardItem) {

                    if (empty($dashboardItem->items)) {
                        continue;
                    }
                    $items = json_decode($dashboardItem->items, true);
                    if (empty($items)) {
                        continue;
                    }
                    foreach ($items as $item) {
                        $itemName = $item['item_name'] ?? '';
                        $viewData = $item['view_data'] ?? [];
                        // ---- CHART INFO SECTION ----
                        if ($dashboardItem->section_name == 'chart_info' && $itemName == 'complaints_chart') {
                            $totalComplaints = $viewData['total'] ?? 0;
                        }
                    }
                }
            }
        }
            
        if(($employeeId>0 && $dealer_id>0 && $totalComplaints >0) && ($user_type == 'RESELLER' || ($user_type == 'EMPLOYEE' && $parent_type == 'RESELLER'))){
            //get the complaints list
            $arr_getComplaintsList = $objComplaints->listcomplain($st=0,$pp=0,$dealer_id,$customerId='',$customerName='',$ticketNo='',$status='',$startDate='',$endDate='',$customerGroup='-1',$compalintAgeingHours='',$complaintCategory='-1',$withIn='',$closedWithIn='',$userId=0,$assineduserId=0,$from_dashboard=0,$installation_address='',$stb_type=0,$userType='RESELLER',$employeeId);					
            //echo "<pre>";print_r($arr_getComplaintsList);
            //echo "<pre>";print_r($this->db->last_query());exit;
            //echo $this->db->last_query(); exit;
            if(count($arr_getComplaintsList)>0)
            {
                $statusCode = 0;
                $statusMessage = 'Success';
            }else{
                $statusMessage = 'No List';
            }
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
            if($totalComplaints == 0){
                $statusMessage = "Access Denied";
                if (!($user_type == 'RESELLER' || ($user_type == 'EMPLOYEE' && $parent_type == 'RESELLER'))) {
                    $statusMessage = "Access denied due to large data.";
                }
            }
        }
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'gettotalcomplaintslist' => $arr_getComplaintsList);
       $this->sendResponse($response);
         }catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    } 
    
    /**
     * get dashboard list
     * @author Rajesh 18-Jan-2022
     * @params {"dealer_id":1}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'getDashboardDataList' => $arr_getDashboardDataList)
     */
    public function getdashboardlist_post(){
        try {
            
        $from_dashboard= isset($this->payload->from_dashboard) ? $this->payload->from_dashboard: 0;
        $dealer_id= isset($this->payload->dealer_id) ? $this->payload->dealer_id: 0;
        $validation_fields=['from_dashboard'=>['isInteger|isRequired','from dashboard'],'dealer_id'=>['isInteger|isRequired','dealer id']];
        $validation_response_array=$this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
         // validation count
         if(count($validation_response_array) > 0){
            // validation error
            $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
            $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
            $response = array(  'status_code'=>$statusCode,
                                'status_msg'=>$statusMessage
                            );
            $this->sendResponse($response);
        }

        $this->load->model(array('wsModel','CustomersModel'));
        $obj = new wsModel();
        $statusCode=1;
        $statusMessage = '';


        $authToken = $this->getAuthToken();
        $employeeId = $this->getEmployeeId();
        $dealerId = $this->getDealerId();
        $arr_getDashboardDataList=array();
        if($employeeId>0 && $dealer_id>0){
            //get the expiry services list
            //get stock_location id
            $location_id = $this->CustomersModel->getResellerLocation($employeeId);
            $user_data = $obj->getUserDetails($employeeId,$dealerId);
            $user_type = isset($user_data->users_type) ? $user_data->users_type: "";
            //write_to_file(" ============ getAllStbs user_data ============ ".json_encode($user_data));
            if(isset($user_data->users_type) && $user_data->users_type == "EMPLOYEE"){
                $employeeId = isset($user_data->parent_id)?$user_data->parent_id:$employeeId;
                $user_type = $user_data->employee_parent_type;
            }
            write_to_file(" ============ getAllStbs employeeId ============ ".json_encode($employeeId));
            
            //echo "<pre>";print_r($data);exit;
            
            $dashboardCounts = [
                'assigned_stbs'   => 0,
                'unassigned_stbs' => 0,
                'total_stbs'      => 0,
                'active_stbs'     => 0,
                'inactive_stbs'   => 0
            ];

            if ($user_type == 'RESELLER' || ($user_type == 'EMPLOYEE' && $parent_type == 'RESELLER')) {
                $this->load->library('dashboard/charts/DashboardData');
                $DashboardData = new DashboardData();
                $getDashboardItemsLibrary = $DashboardData->getDashboardItems($dealerId, $employeeId, $user_type, $employeeId);
                if (!empty($getDashboardItemsLibrary)) {
                    foreach ($getDashboardItemsLibrary as $dashboardItem) {

                        if ($dashboardItem->section_name !== 'stb_info' || empty($dashboardItem->items)) {
                            continue;
                        }

                        $items = json_decode($dashboardItem->items, true);
                        if (empty($items)) continue;

                        foreach ($items as $item) {
                            $name = $item['item_name'] ?? '';
                            $view = $item['view_data'] ?? [];

                            if (isset($dashboardCounts[$name])) {
                                if($name == 'inactive_stbs'){
                                    $name_deactive = 'deactive_stbs';
                                    $dashboardCounts[$name] = $view[$name_deactive] ?? 0;
                                }else if($name == "unassigned_stbs"){
                                        $name_unassigned = "unassigned_stbs";
                                        $dashboardCounts[$name] = $view[$name_unassigned] ?? 0;
                                }else{
                                    $dashboardCounts[$name] = $view[$name] ?? 0;
                                }
                            }
                        }
                    }
                }
                write_to_file(" ============ getAllStbs employeeId4 ============ ".json_encode($employeeId));
                
            }
            write_to_file(" ============ getAllStbs employeeId4 ============ ".json_encode($employeeId));
            $dashboardMap = [
                1 => 'assigned_stbs',
                2 => 'unassigned_stbs',
                3 => 'total_stbs',
                4 => 'active_stbs',
                5 => 'inactive_stbs'
            ];
            $access_flag = 0;
            if ((isset($dashboardMap[$from_dashboard]) && $dashboardCounts[$dashboardMap[$from_dashboard]] == 0) || (!($user_type == 'RESELLER' || ($user_type == 'EMPLOYEE' && $parent_type == 'RESELLER')))) {
                $statusCode = 1;
                $access_flag = 1;
            }
            //write_to_file(" ============ getAllStbs ============ ".json_encode($data));
            $data = [];
            if($access_flag == 0){
                $data = $obj->getAllStbs($employeeId,$dealer_id,$from_dashboard,$location_id);
            }
            if(count($data)>0 && $access_flag == 0)
            {
                $required_keys = [
                    "serial_number",
                    "mac_address",
                    "stock_id",
                    "box_number",
                    "vc_number",
                    "dealer_id",
                    //"backend_setup_id",
                    "reseller_id",
                    "is_assigned",
                    "assigned_date",
                    //"location_id",
                    "customer_name",
                    "account_number",
                    "mobile_no",
                    "customer_id",
                    "cas",
                    "is_active",
                    "activate_date",
                    "installation_address",
                    "service_enddate"
                    //"stock_status",
                    //"device_id",
                    //"is_temp_deactivated",
                ];
                foreach ($data as $key => $value) {
                    $value = (array) $value;
                    $data['getDashboardDataList'][] = $value;
                }
                if (isset($data['getDashboardDataList']) && is_array($data['getDashboardDataList'])) {
                    $arr_getDashboardDataList = array_map(function($item) use ($required_keys) {
                        return array_intersect_key($item, array_flip($required_keys));
                    }, $data['getDashboardDataList']);
                    $statusCode = 0;
                    $statusMessage = 'Success';
                } else {
                    $statusCode = 1;
                    $statusMessage = 'Failed';
                    $arr_getDashboardDataList = array();
                }
            }else{
                $statusMessage = 'No List';
                if($access_flag == 1){
                    $statusMessage = 'Access Denied';
                    if (!($user_type == 'RESELLER' || ($user_type == 'EMPLOYEE' && $parent_type == 'RESELLER'))) {
                        $statusMessage = "Access denied due to large data.";
                    }
                }
            }
        } else{
            $statusCode = 1;
            $statusMessage = 'Authentication Failed';
        }
        $response = array('status_code'=>$statusCode, 'status_msg'=>$statusMessage,'getDashboardDataList' => $arr_getDashboardDataList);
        //write_to_file(" ============ getAllStbs response ============ ".json_encode($response));
        //print_r($response);
       $this->sendResponse($response);
         }catch(Exception $e)
        {
            $this->error_res($e, 200);
        }
    }
    
       /**
     * customer transaction reponse
     * @author Rajesh 25-01-2022
     * @param dealer_id 1 auth_key abcd1234abcd
     * @return array('status_code' => $status_code,'status_msg' =>$status_message,'reason_list' => $reasonList)
     */
    public function customer_transaction_reponseRest_post(){
        try{
        $this->load->model('Selfcare_restservicesmodel');
        $int_employee_id = isset($this->payload->employee_id)?trim($this->payload->employee_id):0;
        $int_dealer_id = isset($this->payload->dealer_id)?trim($this->payload->dealer_id):0;
        //$str_auth_key = isset($this->payload->auth_key)?trim($this->payload->auth_key):'';
        $validation_fields=['employee_id'=>['isInteger|isRequired','employee Id'],'dealer_id'=>['isInteger|isRequired','dealer Id']];
       
        $validation_response_array= $this->number_validation_lib->validateInputDataType_updated($this->payload,$validation_fields);
                 // validation count
                 if(count($validation_response_array) > 0){
                    // validation error
                    $statusCode = isset($validation_response_array['status_code'])?$validation_response_array['status_code']:1;
                    $statusMessage = isset($validation_response_array['status_msg'])?$validation_response_array['status_msg']:"Failed due to data validation error";
                    $response = array(  'status_code'=>$statusCode,
                                        'status_msg'=>$statusMessage
                                    );
                    $this->sendResponse($response);
                }
                
        $status_code = 1;
        $status_message = 'Invaid Details';
        $response_details = array();
        //$customer_id = $this->getCustomerId();
        //$dealer_id = $this->getDealerId();
        $str_auth_key = $this->getAuthToken();
        
        // for lco wallet transaction response 
        if($int_employee_id >0 && $int_dealer_id >0 && $str_auth_key !=''){
            $response_details=$this->Selfcare_restservicesmodel->getlco_transaction_data($int_employee_id,$int_dealer_id);

            if(!empty($response_details) ){
                $status_code=0;
                $status_message='Success';
            }else{
                $status_message='No details Found';
            }
            //$response_data=json_encode(array('status_code' => $status_code,'status_msg' =>$status_message,'response_details'=>$response_details));
            $response=array('status_code' => $status_code,'status_msg' =>$status_message,'response_details'=>$response_details);
                $this->sendResponse($response);
        }
        
                
                $response=array('status_code' => $status_code,'status_msg' =>$status_message,'response_details'=>$response_details);
                $this->sendResponse($response);
        }
        catch(Exception $e)
        {
            $this->error_res($e);
        }
    }
    
    
     /**
     * API service:customerAgingServices
     * @author Narayan 11-07-2024
     * @params {start_date , end_date , serial_number , vc_number, Lco_customer_id}
     * @return array('status_code'=>$statusCode, 'status_msg'=>$statusMessage)
    **/

    public function customerAgingServices_post()
    { 
        print_r($this->payload);exit;
        $aging_start_date = isset($this->payload->start_date) ? $this->payload->start_date : '';
        $aging_end_date = isset($this->payload->end_date) ? $this->payload->end_date : '';
        $str_serial_number = isset($this->payload->serial_number_search) ? $this->payload->serial_number_search : '';
        $str_vc_number = isset($this->payload->vc_number_search) ? $this->payload->vc_number_search : '';
        $str_baid_search = isset($this->payload->baid_search) ? $this->payload->baid_search : '';
        
        $this->load->model('Service_extension_model');
        $usersname = '-1';
        $offset = 0;
        $rows = 1000;
        $product = '-1';
        $product_type = '-1';
        $users = '-1';
        $plugin = '4';
        $int_casserver_type = '-1';
        
        $this->load->library('LovModel');
        $this->load->model('WsModel');
        $dealerId = 1;
        $int_login_employee_id = 1;
        $dealrSettings = $this->LovModel->setDealerSettings($dealerId);
        $userDetails = $this->WsModel->getusersDetails($dealerId, $int_login_employee_id); 
        $report_name = 'AGEING_OF_SERVICES';
        
        $csv_download = 0;
        $extra_parameters = array( 
                  'employee_parent_type'=>isset($userDetails->employee_parent_type)?$userDetails->employee_parent_type:'',
                  'employee_parent_id'=>isset($userDetails->employee_parent_id)?$userDetails->employee_parent_id:'',
                  'dealer_id'=>isset($userDetails->dealer_id)?$userDetails->dealer_id:0,
                  'employee_id'=>isset($userDetails->employee_id)?$userDetails->employee_id:0,
                  'users_type'=>isset($userDetails->users_type)?$userDetails->users_type:'',
                  'identification_for_lco'=>isset($dealrSettings->IDENTIFICATION_FOR_LCO)?$dealrSettings->IDENTIFICATION_FOR_LCO:'',
                  'CHK_DUE_WHILE_ACTIVATION'=>isset($dealrSettings->CHK_DUE_WHILE_ACTIVATION)?$dealrSettings->CHK_DUE_WHILE_ACTIVATION:0,
                  'STB_DEACTIVATE_DAYS'=>isset($dealrSettings->STB_DEACTIVATE_DAYS)?$dealrSettings->STB_DEACTIVATE_DAYS:'',
                  'caf_no'=>isset($dealrSettings->SHOW_CAF)?$dealrSettings->SHOW_CAF:0,
                  'crf_as_accno'=>isset($dealrSettings->CRF_AS_ACCNO)?$dealrSettings->CRF_AS_ACCNO:0,
                  'show_customer_id'=>isset($dealrSettings->SHOW_CUSTOMER_ID)?$dealrSettings->SHOW_CUSTOMER_ID:1,
                  'report_name'=>$report_name,
                  'use_lco_deposits'=>isset($dealrSettings->USE_LCO_DEPOSITS)?$dealrSettings->USE_LCO_DEPOSITS:0,
                  'dealer_settings'=> $dealrSettings,
                  'user_details'=>$userDetails

            );
        $result_data = $this->Service_extension_model->service_going_to_expire($aging_start_date, $aging_end_date, $usersname, $offset, $rows, $product, $product_type, $get_only_recurring = -1, $alcarte_non=-1, '', $users, $str_serial_number, $str_vc_number, $serviceExtWithLcoDeposit=0, $plugin, '', $flag=0, $online_customer_search=0, $selected_base_value=-1, $str_baid_search,$int_casserver_type,$bill_digi_customers=0,$extra_parameters,$csv_download,$order_by=3);
        print_r($result_data);
    }
    
    /**
     * API service:pgTransactionReportDownload
     * @author Narayan 17-07-2024
     * @return array('status_code'=>$statusCode, 'status_msg'=>$status_message)
    **/
    public function pgTransactionReportDownload_get(){
        try{
            $employeeId = $this->getEmployeeId();
            $dealer_id = $this->getDealerId();
            $start_date= date('Y-m-d', strtotime('-3month'));
            $end_date = date('Y-m-d');
            $status_code = 1 ;
            $status_message = 'failure';
            $this->load->model('reportsModel');
            $reports=new reportsmodel();
            $arr_paymentresult = $reports->getPaymentTransactionresult(-1,'','','',1,$start_date,$end_date,0,0,$select_statement='',$csv=0,$dealer_id,$employeeId,'',0,-1,-1,$payment_status=0,$from_mobileapp=1);
            //print_r($arr_paymentresult); 
            if(!empty($arr_paymentresult)){
            $this->load->library('Download_lib');
            $this->download_lib->export_pdf_jsonFpdf($arr_paymentresult,$dealer_id,$fileName="pdf_report");
            }else{
                $response=array('status_code' => $status_code,'status_msg' =>$status_message);
                $this->sendResponse($response);
            }
        } catch (Exception $ex) {
            $this->error_res($e);
        }
    }
    
    /**
     * API service:empCollectionReportDownload
     * @author Narayan 17-07-2024
     * @return array('status_code'=>$statusCode, 'status_msg'=>$status_message)
    **/
    public function empCollectionReportDownload_post(){
        try{
            $employeeId = $this->getEmployeeId();
            $dealerId = $this->getDealerId();
            $fromDate=isset($this->payload->fromDate)?trim($this->payload->fromDate):date('Y-m-01');
            $toDate=isset($this->payload->toDate)?trim($this->payload->toDate):date('Y-m-t');
            $customerInfo = (object)array('fromDate'=>$fromDate, 'toDate'=>$toDate);
            $status_code = 1 ;
            $status_message = 'failure';
            
            if($employeeId != 0 && $dealerId != 0){
                $userType = $obj->getUserType($employeeId,$dealerId);
                $result = $obj->getEmployeeCollection($customerInfo, $employeeId, $dealerId,$userType);
                if(!empty($result)){
                    $this->load->library('Download_lib');
                    $this->download_lib->export_pdf_jsonFpdf($result,$dealerId,$fileName="pdf_report");
                }else{
                    $response=array('status_code' => $status_code,'status_msg' =>$status_message);
                    $this->sendResponse($response);
                }   
            }else{
                $response=array('status_code' => $status_code,'status_msg' =>$status_message);
                $this->sendResponse($response);
            }
            
        } catch (Exception $ex) {
            $this->error_res($e);
        }
    }
    
    public function stb_replacement_post(){
        $employeeId = $this->getEmployeeId();
        $dealerId = $this->getDealerId();
        //write_to_file(" ======== stb_replacement_post payload =====".json_encode($this->payload));
        // json request
            /*
            {
              "serial_number": "SN123456789",
              "account_nmber": "AC987654321",
              "replacement_type_id": 1,
              "amount": "500",
              "receipt_number": "RCPT20250322001",
              "remarks": "Replacement due to damage",
              "replace_serial_number": "RSN123456789",
              "replace_vc_number": "VC987654321",
              "is_permanent_surrender": 0
            }
            */
        //print_r($this->payload);exit;
        $serial_number=isset($this->payload->serial_number)?trim($this->payload->serial_number):"";
        $customer_id=isset($this->payload->account_nmber)?trim($this->payload->account_nmber):"";
        $replacement_type_id=isset($this->payload->replacement_type_id)?trim($this->payload->replacement_type_id):0; // 1- DEFECTIVE,2- UPGRADE,4- SURRENDER,6- OTHERS
        $amount=isset($this->payload->amount)?trim($this->payload->amount):"0";
        $receipt_number=isset($this->payload->receipt_number)?trim($this->payload->receipt_number):"";
        $remarks=isset($this->payload->remarks)?trim($this->payload->remarks):"";
        $replace_serial_number=isset($this->payload->replace_serial_number)?trim($this->payload->replace_serial_number):"";
        $replace_vc_number=isset($this->payload->replace_vc_number)?trim($this->payload->replace_vc_number):"";
        $is_permanent_surrender=isset($this->payload->is_permanent_surrender)?trim($this->payload->is_permanent_surrender):0;
        $pair_condition=isset($this->payload->pair_condition)?trim($this->payload->pair_condition):2; // 1 = Unpair, 2 = No Unpair

        $make_it_defective = 0; // Need more clarity on this variable ,this is for unassigned defective
        $keepServices = 1;      // 1-activate services on new box,2-remove all services
        $stb_replacement_request_id = ""; // Need more clarity on this variable

        //$customer_id = $this->WsModel->get_customer_id($account_nmber,$employeeId,"RESELLER");
        $stock_id = 0;
        $status_code = 1;
        $status_message = "Invalid Serialnumber";
        //$replace_serial_number = "VAAAABY235210950";
        //$replace_vc_number = "1200032609";
        $old_stock_id = $this->WsModel->getStockId_of_STB($dealerId,$serial_number);
        if(!empty($replace_serial_number)){
            $stock_id = $this->WsModel->getStockId_of_STB($dealerId,$replace_serial_number,"");
        }
        else if(!empty($replace_vc_number)){
            $status_message = "Invalid VC number";
            $stock_id = $this->WsModel->getStockId_of_STB($dealerId,"",$replace_vc_number);
        }
        $response_details = array();
        if($old_stock_id == 0 || ($replacement_type_id != 4 && $stock_id == 0)){ // Not surrender needed Replacement box stock_id
            $response_details = array("response_message"=>$status_message,"errorMessage"=>$status_message);
            $response=array('status_code' => $status_code,'status_msg' =>$status_message,'response_details'=>$response_details);
            write_to_file(" ======== stb_replacement_post response =====".json_encode($response));
            $this->sendResponse($response);
            exit;
        }
        $this->load->library('StbReplacementValidations');
        $replacement_post_data_array = array(
            'dealer_id'         =>  $dealerId,
            'employee_id'       =>  $employeeId,
            'replacement_type'  =>  $replacement_type_id, // 1- DEFECTIVE,2- UPGRADE,4- SURRENDER,6- OTHERS
            'make_it_defective' =>  $make_it_defective,
            'keepServices'      =>  $keepServices,
            'customer_id'       =>  $customer_id,
            'stock_id'          =>  $stock_id,
            'old_stock_id'      =>  $old_stock_id,
            'reseller_id'       =>  $employeeId,
            'amount'            =>  $amount,
            'receipt_no'        =>  $receipt_number,
            'remarks'           =>  $remarks,
            'surrender'         =>  $is_permanent_surrender,
            'pair_condition'    =>  $pair_condition,
            'stb_replacement_request_id' => $stb_replacement_request_id
        );
        write_to_file(" ======== stb_replacement_post replacement_post_data_array =====".json_encode($replacement_post_data_array));
        $response_details = $this->stbreplacementvalidations->dostbreplacement($replacement_post_data_array,$operation_name="STB_replacement_from_lco_mobile_app");
        //print_r($response_details);exit;
        write_to_file(" ======== stb_replacement_post response_details =====".json_encode($response_details));
        if($response_details['status'] == 1){
            $status_code = 0;
            $status_message = "success";
        }
        $response=array('status_code' => $status_code,'status_msg' =>$status_message,'response_details'=>$response_details);
        write_to_file(" ======== stb_replacement_post response =====".json_encode($response));
        $this->sendResponse($response);
    }

    /**
     * API service: SingleView Deduction Logs Last three months
     * @author Satyam 15-12-2025
     * @return array('status_code'=>$statusCode, 'status_msg'=>$status_message)
    **/
    public function customer_deduction_logs_post()
    {
        try {
            $employeeId = (int) $this->getEmployeeId();
            $dealerId   = (int) $this->getDealerId();

            $dateRange  = isset($this->payload->dateRange) ? trim((string)$this->payload->dateRange) : 'current_month';
            $customerId = isset($this->payload->customerId) ? (int) trim((string)$this->payload->customerId) : 0;
            //$customerId = 835324;
            // Pagination (keep defaults)
            $rows   = 1000;
            $offset = 0;

            // Normalize / whitelist dateRange
            $allowedRanges = ['current_month', 'last_3_months', 'all_time'];
            if (!in_array($dateRange, $allowedRanges, true)) {
                $dateRange = 'current_month';
            }

            // Compute start date (use NULL for all_time)
            $startDate = null;
            if ($dateRange === 'current_month') {
                $startDate = date('Y-m-01');
            } elseif ($dateRange === 'last_3_months') {
                // last 3 months from today
                $startDate = date('Y-m-d', strtotime('-3 months'));
            } elseif ($dateRange === 'all_time') {
                $startDate = null; // important: let model skip date filter
            }

            if ($employeeId > 0 && $dealerId > 0 && $customerId > 0) {
                $this->load->model('Customer360Model');

                // 3rd param you pass as 0 kept same; if it's a filter flag, keep it.
                $paymentServicesArray = $this->Customer360Model->getPaymentDetails(
                    $customerId,
                    $startDate,
                    0,
                    $rows,
                    $offset
                );
                if (!empty($paymentServicesArray)) {
                    foreach ($paymentServicesArray as &$row) {
                        if (!empty($row['date'])) {
                            $row['date'] = date('d-m-Y H:i:s', strtotime($row['date']));
                        }
                    }
                    unset($row); // safety
                }
                $response = [
                    'status_code'   => 0,
                    'status_msg'    => 'success',
                    'deduction_logs'=> is_array($paymentServicesArray) ? $paymentServicesArray : []
                ];
                return $this->sendResponse($response);
            }

            // Better message so API consumer knows what is missing
            $missing = [];
            if ($employeeId <= 0) $missing[] = 'employeeId';
            if ($dealerId <= 0)   $missing[] = 'dealerId';
            if ($customerId <= 0) $missing[] = 'customerId';

            $response = [
                'status_code' => 1,
                'status_msg'  => 'Invalid request: missing/invalid ' . implode(', ', $missing)
            ];
            return $this->sendResponse($response);

        } catch (Exception $ex) {
            return $this->error_res($ex);
        }
    }

    
}
