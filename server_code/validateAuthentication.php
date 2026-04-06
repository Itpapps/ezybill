<?php
	class validateAuthentication extends CI_Controller
	{
		public function __construct()
		{
			parent::__construct();
			$this->load->model('validateauthenticationmodel');
			//$this->load->helper('debug');
			//write_to_file("@BMS");
		}
		public function wsdl()
		{
			//Open file and read XML
			$file_contents =  file_get_contents('ezybillauth.wsdl');
			header('Content-Type: text/xml');
			echo $file_contents;
		}
		public function index() 
		{
			if (isset($_GET['wsdl']))
			{	
				$this->wsdl();
				die();
			}
			ini_set('soap.wsdl_cache_limit', 0);
			ini_set('soap.wsdl_cache_ttl', 0);
			$base_url = $this->config->item('base_url');
			$wsdl = $base_url.'/index.php/validateAuthentication/wsdl';
			$url['uri'] = $base_url.'/index.php/validateAuthentication';
			if ($base_url=='/')
				$server = new SOAPServer('ezybillauth.wsdl');
			else
				$server = new SOAPServer($wsdl, $url);
			$server->setClass('validateAuthentication');
			$server->handle();
		}
		//function which validates user authenticaiton by rakesh on 06-01-2014
		public function validateUserAuthentication($authenticationDetails)
		{
			$debug=1;
			$statusCode = 1;
			$statusMessage = 'Failed to authenticate';
			$key = '';
			$success = 1;
			$result='';
			$ipAddress = '';
			$parentEmployeeId = 0;
			$app_theme_color= 1;
			$app_dashboard = 1;
			$app_logo_path = '';
			$ezybill_version = 'V1';
			$check_registration = 1;
			$registration_required = 1;
			$key=trim($authenticationDetails->smsCode);
			$appTypeId=trim($authenticationDetails->appTypeId);
			$app_type_auto_id = (isset($authenticationDetails->appTypeAutoId) && $authenticationDetails->appTypeAutoId!='')?$authenticationDetails->appTypeAutoId:0;
			if((int)$appTypeId == 3 && (int)$app_type_auto_id == 0){
				$imei_check=0;
			}
			if($debug)write_to_file("logiindataaaa".json_encode($authenticationDetails));
			if(strlen($key)>4 && (int)$appTypeId == 2){
				$userName = substr($authenticationDetails->smsCode,4);
				$mso_key = substr($authenticationDetails->smsCode,0,4);
				$imei=$authenticationDetails->imei;
				$appTypeId=$authenticationDetails->appTypeId;
				$this->load->model('bms_customersmodel');
				$this->load->model('appsmodel');
				
				$get_url_details=$this->bms_customersmodel->getBMSDealerInfo($mso_key);
				if($debug)write_to_file("get_url_details query ".json_encode($this->db->last_query()));
		 		if($debug)write_to_file("get_url_details".json_encode($get_url_details));
				$get_url = $get_url_details->parent_url;
				$http_flag= $get_url_details->http_flag;
				$ezybill_version= isset($get_url_details->ezybill_version)?$get_url_details->ezybill_version:"V1";
				if($http_flag){
					$get_url = "https://".$get_url;
				}
				else{
					$get_url = "http://".$get_url;
				}
				
				$get_dealer_id = $get_url_details->dealer_id;
				$get_parent_id = $get_url_details->code;
				$createdBy = $get_url_details->created_by;
				$apps_max_limit = $get_url_details->apps_max_limit;
				//if(empty(trim($userName)) || empty(trim($get_url)) || empty(trim($get_parent_id)))
				if(trim($userName) == false || trim($get_url)== false|| trim($get_parent_id)== false)
				{
					$statusMessage='Enter Valid MSO KEY or username';
					$success = 0;

				}

				$Registered_members_count=$this->bms_customersmodel->getRegisteredCount($get_url);	
				$members_count = $Registered_members_count->count;
				//write_to_file("members_count".$apps_max_limit);
				if($members_count > $apps_max_limit && $success == 1){
					$statusMessage ='Maximum reigistrations reached, Max limit is : '.$apps_max_limit;
	
				}
				else if($success == 1){
						$authKey = ($this->config->item('bms_auth_key') && strlen(trim($this->config->item('bms_auth_key'))) > 0)?trim($this->config->item('bms_auth_key')):'';	
								$authKey = md5($authKey);
					//print_r($get_url);die();
					$xmlEmployeeDetails = str_replace(array("&amp;", "&"), array("&", "&amp;"),@file_get_contents($get_url."/apps/webservices/get_employee_details.php?dealer_id=$get_parent_id&user_name=$userName&ak=$authKey"));	
					if($debug)write_to_file("employee Data chcking url ".$get_url."/apps/webservices/get_employee_details.php?dealer_id=$get_parent_id&user_name=$userName&ak=$authKey");
					$items = simplexml_load_string($xmlEmployeeDetails);
					$empDataXML = simplexml_load_string($xmlEmployeeDetails, "SimpleXMLElement", LIBXML_NOCDATA);
					$empDatajson = json_encode($empDataXML);
					$empDataarray = json_decode($empDatajson,TRUE);
					if($debug)write_to_file("employee Data chcking".json_encode($empDataarray));
					if(isset($empDataarray[0]))
					{	
						
							$statusMessage ="Employee Details Not Found";
					}	
					else
					{
						
						if(isset($items) && $items==TRUE ){	
					    	$extraParams = array();
							$extraParams['get_dealer_id'] = $get_dealer_id;
							$extraParams['appTypeId'] = $appTypeId;
							$extraParams['created_by'] = $createdBy;
							$extraParams['parent_url'] = $get_url;
							$extraParams['imei'] = $imei;
							$extraParams['userName'] = $userName;
				        	$authenticationDetails->smsCode = $this->insertRegistrationQueries($items,$extraParams,$check=0);
				        	$result=$authenticationDetails->smsCode;
				        	
						}
						else{
							$statusMessage ="please check url or userName";
						
						}
						if($debug)write_to_file("insertRegistrationQueries".json_encode($authenticationDetails->smsCode));
					}
				}
				
				
				if($result == '' && strlen($key) != 10){
					if($debug){
						write_to_file("---------------Result :: ".json_encode(array('statusCode'=>$statusCode,
						'statusMessage'=>$statusMessage,
						'ipAddress'=>$ipAddress,
						'employeeId'=>$parentEmployeeId,
						'appThemeColor'=>$app_theme_color,
						'appDashboard'=>$app_dashboard,
						'appLogoPath'=>$app_logo_full_path,
						'registrationRequired'=>$registration_required,
						'version'=>$ezybill_version
						)));
					}
	        		return (array('statusCode'=>$statusCode,
					'statusMessage'=>$statusMessage,
					'ipAddress'=>$ipAddress,
					'employeeId'=>$parentEmployeeId,
					'appThemeColor'=>$app_theme_color,
					'appDashboard'=>$app_dashboard,
					'appLogoPath'=>$app_logo_full_path,
					'registrationRequired'=>$registration_required,
					'version'=>$ezybill_version
					));
	        	}
			}
			
						if(((isset($authenticationDetails->smsCode) && trim($authenticationDetails->smsCode) != '') || (isset($authenticationDetails->imei) && trim($authenticationDetails->imei) != '')) && isset($authenticationDetails->appTypeId) && trim($authenticationDetails->appTypeId) != '')
					{
						$obj_validateAuthentication = new validateauthenticationmodel();

						//if we get app_type_auto_id
						if($app_type_auto_id>0){
							$app_path = $obj_validateAuthentication->getAppPath($app_type_auto_id);
							if($app_path!=''){
								$check_registration = 0;
								$registration_required = 0;
								$statusCode = 0;
								$statusMessage = 'Registered successfully';
								$ipAddress = $app_path."/index.php/wsController";
							}
						}

						if($check_registration){
							$str_smsCode = trim($authenticationDetails->smsCode);
							$str_imei = trim($authenticationDetails->imei);
							//$str_userName = trim($authenticationDetails->userName);
							//$str_passWord = trim($authenticationDetails->passWord);
							$int_appTypeId = trim($authenticationDetails->appTypeId);
							$imeiValidNumber = trim($authenticationDetails->imeiValidNumber); //Newly added by DURGA for check imei exist or not on 13-06-2016
							
							//for first time login both sms code and imei will be received as parameters
							if($str_smsCode != '' && $str_imei != '' && $imeiValidNumber==0)
							{
								//get app id based on sms code
								if($debug)write_to_file("str_smsCode".json_encode($str_smsCode));
								$int_appId = $obj_validateAuthentication->getAppIdOnSmsCode($str_smsCode,$imei_check);
								if($debug)write_to_file("-------getAppIdOnSmsCode :: ".$int_appId);
								if($int_appId != 0)
								{
									//get employee id based on app id 
									$int_employeeId = $obj_validateAuthentication->getEmployeeIdOnAppId($int_appId);
									if($debug)write_to_file("-------int_employeeId :: ".$int_employeeId);
									if($int_employeeId != 0)
									{
										//check whether that employee exist or not based on username, password and app type id
										/*$int_isEmployeeExist = $obj_validateAuthentication->checkEmployeeExist($str_userName,$str_passWord,$int_appTypeId);
										if($int_isEmployeeExist)
										{*/
											//check whether an application of same apptype exist with that imei
											//if(!$obj_validateAuthentication->checkAppTypeWithSameImei($int_appTypeId,$str_imei))
											//{
												//update imei based on 
												if($obj_validateAuthentication->updateImei($int_appId,$str_imei))
												{
													//get the ip address 
													$ipAddress = $obj_validateAuthentication->getIpAddress($int_appId);
													$parentemployee_Det = $obj_validateAuthentication->getParentEmployeeDetails($int_employeeId,$int_appTypeId);
													if(isset($parentemployee_Det) && count($parentemployee_Det)>0){
														if($debug)write_to_file("-------details :: ".json_encode($parentemployee_Det));
														$parentEmployeeId=$parentemployee_Det->parent_emp_id;
														$app_theme_color=$parentemployee_Det->app_theme_color;
														$app_dashboard=$parentemployee_Det->app_dashboard;										
														$app_logo_path=$parentemployee_Det->app_logo_path;	

														if((int)$appTypeId == 2){
															$app_url = $parentemployee_Det->parent_url;
															$app_url_http_flag = $parentemployee_Det->http_flag;
															if($app_url_http_flag){
																$ipAddress = "https://".$app_url."/index.php/wsController";
															}
															else{
																$ipAddress = "http://".$app_url."/index.php/wsController";
															}
															if($debug)write_to_file("-------url details :: ".$ipAddress);
														}
													}
													
													$statusCode = 0;
													$statusMessage = 'Registered successfully';
												}
												else
												{
													$statusMessage = 'Failed to update the imei';
												}
											//}
											//else
											//{
											//		$statusMessage = 'An apptype with the same IMEI already exist';
											//}
										/*}
										else
										{
											$statusMessage = 'Employee does not exist';
										}*/
									}
									else
									{
										$statusMessage = 'Employee does not exist';
									}
								}
								else
								{
									$statusMessage = 'App does not exist';
								}
								
							}
							elseif($str_smsCode == '' && $str_imei != '' && $imeiValidNumber==0)//login from 2nd time onwards only imei will be received as parameter
							{
								
								//get employee id based on app id, user name and password
								//$int_employeeId = $obj_validateAuthentication->checkEmployeeExist($str_userName,$str_passWord,$int_appTypeId,$str_imei);
								//write_to_file("get_url_details");
								$int_employeeId = $obj_validateAuthentication->getEmployeeIdOnIMEI($str_imei,$int_appTypeId);
								if($debug)write_to_file("-------getEmployeeIdOnIMEI :: ".$int_employeeId);
								if($int_employeeId > 0)
								{
									//get app id based on employee id
									$int_appId = $obj_validateAuthentication->getAppIdOnEmployeeId($int_employeeId,$int_appTypeId);
									if($debug)write_to_file("-------getAppIdOnEmployeeId :: ".$int_appId);
									if($int_appId > 0)
									{
										//function to check the App subscription expiry Done By DURGA
										$getexpiryDate =  $obj_validateAuthentication->getSubscriptionExpiryDate($int_employeeId,$int_appTypeId);
										if($debug)write_to_file("-------getSubscriptionExpiryDate :: ".$int_appId);
										if($getexpiryDate == 1)
										{
											//get the ip address 
											$ipAddress = $obj_validateAuthentication->getIpAddress($int_appId);
											$statusCode = 0;
				                            $parentemployee_Det = $obj_validateAuthentication->getParentEmployeeDetails($int_employeeId,$int_appTypeId);
				                            if($debug)write_to_file("-------getParentEmployeeDetails :: ".json_encode($parentemployee_Det));
											if(isset($parentemployee_Det) && count($parentemployee_Det)>0){
												$parentEmployeeId=$parentemployee_Det->parent_emp_id;
												$app_theme_color=$parentemployee_Det->app_theme_color;
												$app_dashboard=$parentemployee_Det->app_dashboard;
												$ezybill_version=isset($parentemployee_Det->ezybill_version)?$parentemployee_Det->ezybill_version:"V1";													
												$app_logo_path=$parentemployee_Det->app_logo_path;
												if((int)$appTypeId == 2){
													$app_url = $parentemployee_Det->parent_url;
													$app_url_http_flag = $parentemployee_Det->http_flag;
													if($app_url_http_flag){
														$ipAddress = "https://".$app_url."/index.php/wsController";
													}
													else{
														$ipAddress = "http://".$app_url."/index.php/wsController";
													}
													if($debug)write_to_file("-------url  :: ".$ipAddress);
												}
											}
											$statusMessage = 'Authenticated successfully';
										//write_to_file("Authenticated successfully");
										}
										else
										{
											$statusMessage = 'Your app subscription expired, please renewal your app subscription.';
										}
									}
									else
									{
										$statusMessage = 'App does not exist for the employee';
									}
								}
								else
								{
									$statusMessage = 'Employee or App does not exist';
								}
							}				
							elseif($int_appTypeId >0 && $str_imei !='' && $imeiValidNumber==1)
							{					
								$int_employeeId = $obj_validateAuthentication->getEmployeeIdOnIMEI($str_imei,$int_appTypeId);					
								if($int_employeeId > 0)
								{						
									// $statusCode = 0;
									// $statusMessage = 'Authenticated successfully';
									//get app id based on employee id
									$int_appId = $obj_validateAuthentication->getAppIdOnEmployeeId($int_employeeId,$int_appTypeId);
									if($int_appId > 0)
									{
										//function to check the App subscription expiry Done By DURGA
										$getexpiryDate =  $obj_validateAuthentication->getSubscriptionExpiryDate($int_employeeId,$int_appTypeId);
										if($getexpiryDate == 1)
										{
										//get the ip address 
										$ipAddress = $obj_validateAuthentication->getIpAddress($int_appId);
										$statusCode = 0;																
										$parentEmployeeId = $obj_validateAuthentication->getParentEmployeeId($int_employeeId,$int_appTypeId);
										$statusMessage = 'Authenticated successfully';
										}
										else
										{
											$statusMessage = 'Your app subscription expired, please renewal your app subscription.';
										}
									}
									else
									{
										$statusMessage = 'App does not exist for the employee';
									}
								}
								else
								{
									$statusMessage = 'Employee or App does not exist';					
								}
							}
						}
						
						
					}
					
					$ip_split = explode('index.php', $ipAddress);
		            $app_logo_full_path=$ip_split[0].$app_logo_path;
		            if($debug){
						write_to_file("---------------Result :: ".json_encode(array('statusCode'=>$statusCode,
						'statusMessage'=>$statusMessage,
						'ipAddress'=>$ipAddress,
						'employeeId'=>$parentEmployeeId,
						'appThemeColor'=>$app_theme_color,
						'appDashboard'=>$app_dashboard,
						'appLogoPath'=>$app_logo_full_path,
						'registrationRequired'=>$registration_required,
						'version'=>$ezybill_version
						)));
					}
					return (array('statusCode'=>$statusCode,
					'statusMessage'=>$statusMessage,
					'ipAddress'=>$ipAddress,
					'employeeId'=>$parentEmployeeId,
					'appThemeColor'=>$app_theme_color,
					'appDashboard'=>$app_dashboard,
					'appLogoPath'=>$app_logo_full_path,
					'registrationRequired'=>$registration_required,
					'version'=>$ezybill_version
					));
			
		}
		
		
	//function to check app version by Durga on 18-05-2016
	public function appVersionCheck($versionInfo)
	{
		$versionName = (isset($versionInfo->appVersionName) && trim($versionInfo->appVersionName) != '')?trim($versionInfo->appVersionName):NULL;
		$versionCode = (isset($versionInfo->appVersionCode) && trim($versionInfo->appVersionCode) != '')?trim($versionInfo->appVersionCode):NULL;
		$appTypeId = (isset($versionInfo->appTypeId) && trim($versionInfo->appTypeId) != '')?trim($versionInfo->appTypeId):NULL;
		$appClientName = (isset($versionInfo->appclientname))?trim($versionInfo->appclientname):'';
		$statusCode = 1;
		$statusMessage = 'Failed.';
		write_to_file("---- server_data ---".json_encode($_SERVER));
		write_to_file(' ======= versionInfo ======== '.json_encode($versionInfo));
		//$this->write_to_file('$versionName'.$versionName);
		//$this->write_to_file('$versionCode'.$versionCode);
		//write_to_file('$versionName'.$versionName);
		//write_to_file('$versionCode'.$versionCode);
		$appClientName = "BANGLALCOAPP";
		if(isset($versionName) && isset($versionCode) && isset($appTypeId) && isset($appClientName))
		{
			//if($appClientName == 'ACTLCOAPP' || $appClientName == 'BANGLALCOAPP'){
			if($appClientName == 'BANGLALCOAPP'){
				$statusCode = 0;
				$statusMessage = 'Success.';
			} else{
				$obj = new validateauthenticationmodel();
				if($obj->checkAppVersion($versionName,$versionCode,$appTypeId,$appClientName))
				{
					$statusCode = 0;
					$statusMessage = 'Success.';	
				}
				else
				{
					$statusCode = 1;
					$statusMessage = 'Please update your app to the latest version.';			
				}
			}
		}
		write_to_file(' ======= versionInfo Response ======== '.json_encode(array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage)));
		return (array('statusCode'=>$statusCode,'statusMessage'=>$statusMessage));		
	}

	//function for validating login by Swaroop
	public function validateLogin($logindetails){
		$statusCode = 1;
		$statusMessage = 'Invalid Login';
		$userName = (isset($logindetails->UserName) && trim($logindetails->UserName) != '')?trim($logindetails->UserName):'';
		$passWord = (isset($logindetails->PassWord) && trim($logindetails->PassWord) != '')?trim($logindetails->PassWord):'';
		$imei = (isset($logindetails->imei) && trim($logindetails->imei) != '')?trim($logindetails->imei):'';
		$appTypeId = (isset($logindetails->appTypeId) && trim($logindetails->appTypeId)!= '')?trim($logindetails->appTypeId):0;
		$appTypeAutoId = (isset($logindetails->appTypeAutoId) && trim($logindetails->appTypeAutoId) != '')?trim($logindetails->appTypeAutoId):0;
		
		if($userName !='' && $passWord !='' && $imei !='' && $appTypeId >0 && $appTypeAutoId>0){
			$statusCode = 0;
			$statusMessage = 'Success';
		}
	
		return (array('statusCode'=>$statusCode,
					  'statusMessage'=>$statusMessage
				));
	}

	/*public function bms_new_registration($logindetails){
		$statusCode = 1;
		$statusMessage = 'Registration Failed';
		$userName = (isset($logindetails->UserName) && trim($logindetails->UserName) != '')?trim($logindetails->UserName):'';
		$mso_key = (isset($logindetails->mso_key) && trim($logindetails->mso_key) != '')?trim($logindetails->mso_key):'';
		$imei = (isset($logindetails->imei) && trim($logindetails->imei) != '')?trim($logindetails->imei):'';
		$appTypeId = (isset($logindetails->appTypeId) && trim($logindetails->appTypeId)!= '')?trim($logindetails->appTypeId):0;
		//write_to_file("logiindataaaa".json_encode($logindetails));
		$this->load->model('bms_customersmodel');
		$this->load->model('appsmodel');
		if(empty($mso_key))
		{
			$statusMessage='Enter Valid MSO KEY';
			return (array('statusCode'=>$statusCode,
					  'statusMessage'=>$statusMessage
				));
		}

		$get_url_details=$this->bms_customersmodel->getBMSDealerInfo($mso_key);
		
		if(empty($get_url_details)) 
		{
			
			$authenticationDetails = new stdClass;
			$authenticationDetails->smsCode = $mso_key;
			$authenticationDetails->imei = $imei;
			$authenticationDetails->appTypeId = $appTypeId;
			$authenticationDetails->imeiValidNumber = 0;//Currently sendig static: todo
			//$return_data=array();
	 		return $return_data=$this->validateUserAuthentication($authenticationDetails);
		}
		//write_to_file("get_url_details".json_encode($get_url_details));
		$get_url = $get_url_details->parent_url;
		$get_url = "http://".$get_url;
		$get_dealer_id = $get_url_details->dealer_id;
		$get_parent_id = $get_url_details->code;
		$createdBy = $get_url_details->created_by;
		$apps_max_limit = $get_url_details->apps_max_limit;
		//if(empty(trim($userName)) || empty(trim($get_url)) || empty(trim($get_parent_id)))
		if(trim($userName) == false || trim($get_url)== false|| trim($get_parent_id)== false)
		{
			return (array('statusCode'=>$statusCode,
					  'statusMessage'=>$statusMessage
				));
		}

		//$get_url = "http://dddddddddd";
		$Registered_members_count=$this->bms_customersmodel->getRegisteredCount($get_url);	
		$members_count = $Registered_members_count->count;
		//write_to_file("members_count".$members_count);
		if($members_count > $apps_max_limit){
			//$statusCode = $members_count;
			$statusMessage ='Maximum reigistrations reached, Max limit is : '.$members_count;
			return (array('statusCode'=>$statusCode,
					  'statusMessage'=>$statusMessage
				));
		}
		
		$authKey = ($this->config->item('bms_auth_key') && strlen(trim($this->config->item('bms_auth_key'))) > 0)?trim($this->config->item('bms_auth_key')):'';	
					$authKey = md5($authKey);
		$xmlEmployeeDetails = str_replace(array("&amp;", "&"), array("&", "&amp;"),@file_get_contents($get_url."/apps/webservices/get_employee_details.php?dealer_id=$get_parent_id&user_name=$userName&ak=$authKey"));	
//write_to_file($get_url."/apps/webservices/get_employee_details.php?dealer_id=$get_parent_id&user_name=$userName&ak=$authKey");
		$items = simplexml_load_string($xmlEmployeeDetails);
		$empDataXML = simplexml_load_string($xmlEmployeeDetails, "SimpleXMLElement", LIBXML_NOCDATA);
		$empDatajson = json_encode($empDataXML);
		$empDataarray = json_decode($empDatajson,TRUE);
		//write_to_file("employee Data chcking".json_encode($empDataarray));
		if(isset($empDataarray[0]))
		{	
			//write_to_file("if*************".$members_count);
			return (array('statusCode'=>$statusCode,
					  'statusMessage'=>"Employee Details Not Found"
				));	
		}	
		else
		{
			//write_to_file("else**********".$members_count);
			if(isset($items) && $items==TRUE ){	
		    	$extraParams = array();
				$extraParams['get_dealer_id'] = $get_dealer_id;
				$extraParams['appTypeId'] = $appTypeId;
				$extraParams['created_by'] = $createdBy;
				$extraParams['parent_url'] = $get_url;
				$extraParams['imei'] = $imei;
				$extraParams['userName'] = $userName;
				//write_to_file("extraParams".json_encode($extraParams));
	        	return $this->insertRegistrationQueries($items,$extraParams,$check=1);
			}
			else{
				return (array('statusCode'=>$statusCode,
					  'statusMessage'=>"please check url or userName"
				));	
			}
			//write_to_file("else**********extraParams".json_encode($extraParams));
		}
		
	}*/
	 public function insertRegistrationQueries($empDetails,$extraParams,$check)
	 {
	 		$statusCode = 1;
	 		foreach ($empDetails as $empData) {
				$parent_employee_id = $empData->employee_id;
        		$first_name = $empData->first_name;
        		$last_name = $empData->last_name;
        		$mobile_no = $empData->mobile_no;
        		$email = $empData->email;
        		$username = $empData->username;
        		$users_type = $empData->users_type;
        		$code = $empData->code;
        		$use_android = $empData->use_android;
        	}
        		//write_to_file("use_android".$use_android);
        		/*if($use_android != 1 && $check == 1){
        			return (array('statusCode'=>$statusCode,
					  	'statusMessage'=>'Permission Not given please contact'
						));
        		}*/
		 		$createdBy = $extraParams['created_by'];
		     	$get_url = $extraParams['parent_url'];
		     	$host_url = $extraParams['parent_url'].'/index.php/wsController';
		 		$bms_dealer_id = $extraParams['get_dealer_id'];
        		$appTypeId = $extraParams['appTypeId'];
        		$imei = $extraParams['imei'];
        		$bmsUserName = $extraParams['userName'];
				$last_insert_id=true;
				/*$appIdData = $this->appsmodel->checkingAppActivationExist(null,$imei);
		        	if(count($appIdData)>0)
		        	{	
		        		//write_to_file("Already IMEI".$use_android);
		        		return (array('statusCode'=>$statusCode,
					  	'statusMessage'=>'Already IMEI("'.$imei.'") Exist'
						));
						$statusMessage='Already IMEI("'.$imei.'") Exist';
		        	}
				$bmsEmployeeData = $this->appsmodel->checkingEmployeeExist($bmsUserName);*/
				//write_to_file("After Query");
				
				//write_to_file("Resulkt".json_encode($bmsEmployeeData));
				/*if(count($bmsEmployeeData)>0)
				{

					$bmsEmployeeId = $bmsEmployeeData[0]->employee_id;
					//write_to_file("BMS Employee ".$bmsEmployeeId);
					$appIdData = $this->appsmodel->checkingAppActivationExist($bmsEmployeeId,$imei);
		        	if(count($appIdData)>0)
		        	{	
		        		return (array('statusCode'=>$statusCode,
					  	'statusMessage'=>'Already Activated Please enter updated sms_key'
						));
						$statusMessage='Already Activated Please enter updated sms_key';

		        	}
				}*/
				//else
				//{	
        			$bmsEmployeeId = $this->appsmodel->saveEmployeeDetails($first_name,$last_name,$mobile_no,$email,$username,$users_type,$parent_employee_id,$bms_dealer_id,$appTypeId,$code,$last_insert_id);
        			if($debug)write_to_file("saveEmployeeDetails".json_encode($bmsEmployeeId));
        		//}	
				$str_startDate = date('Y-m-d');
        		$str_endDate   = date('Y-m-d', strtotime('+1 years'));
        		$dec_price     = 0;
        		$int_subscriptionType=5;
		        $int_status = 1;//active
		        

        		$latest_app_id = $this->appsmodel->saveApp($appTypeId,$str_imei='',$bmsEmployeeId,$host_url,$createdBy,true,$int_status);
        		if($debug)write_to_file("saveApp".json_encode($latest_app_id));
	       		$this->appsmodel->saveAppEmployeeMap($bmsEmployeeId,$createdBy,$latest_app_id,$last_insert_id,$int_status);
	       		//if($debug)write_to_file("saveAppEmployeeMap".json_encode($latest_app_id));
        		$this->appsmodel->saveAppSubscription($str_startDate,$str_endDate,$int_subscriptionType,$dec_price,$createdBy,$latest_app_id,$int_status);
        		$str_smsCode = $this->appsmodel->generateSMSCode($latest_app_id,$createdBy,$last_insert_id);
        		if($debug)write_to_file("generateSMSCode".json_encode($str_smsCode));
        		//write_to_file("str_smsCode".json_encode($str_smsCode));
		 		//$this->appsmodel->updateAppStatus($int_status,$latest_app_id);
				//$this->appsmodel->updateAppEmpMapStatus($int_status,$latest_app_id);
		 		//$this->appsmodel->updateAppSubscriptionStatus($int_status,$latest_app_id);
		 		if($check == 1){
		 			$authenticationDetails = new stdClass;
					$authenticationDetails->smsCode = $str_smsCode;
					$authenticationDetails->imei = $imei;
					$authenticationDetails->appTypeId = $appTypeId;
					$authenticationDetails->imeiValidNumber = 0;//Currently sendig static: todo
					//$return_data=array();
			 		return $return_data=$this->validateUserAuthentication($authenticationDetails);
			 		//write_to_file(json_encode($return_data));
			 		//return $return_data;
		 		}else{
		 			return $str_smsCode;
		 		}
        		
  	}	
		
}
?>