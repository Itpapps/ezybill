<?php

/**
 * Encryption_lib Class
 * Contains the functions to do encryption
 * 
 * @filesource Encryption_lib.php
 * @author     Archana 
 * @date       22-06-2020
 */

class Encryption_lib {

	public function __construct(){
		//creating codeigniter instance
        $this->CI =& get_instance();
        $this->CI->load->model("Api_gateway_model");
	}

    /**
     * This method is used to encrypt the data. after encryption we are sending encrypted data in result array. result array contains status,msg,decrypted_data
     * 
     * @author Archana 
     * @date   27-06-2020
     * @param  array $params The data that you want to encrypt
     * @return array $result
     */
    public function do_encryption($params,$encryption_key){
        //$arr_params = json_decode($params,true);
        //$encryptedData = isset($arr_params['payload'])?$arr_params['payload']:''; //encrypted data
        $result['status'] = 0;
        $result['msg'] = '';
        if($encryption_key == '' || $params == '')
        {
            $result['msg'] = 'Invalid Request';
            $result['encrypted_data'] = '';
        } else {
            $cipher     = 'AES-256-CBC';
	        $options    = OPENSSL_RAW_DATA;
	        $hash_algo  = 'sha256';
	        $sha2len    = 32;
	        $ivlen = openssl_cipher_iv_length($cipher);
	        $iv = openssl_random_pseudo_bytes($ivlen);
	        $ciphertext_raw = openssl_encrypt($params, $cipher, $encryption_key, $options, $iv);
	        $hmac = hash_hmac($hash_algo, $ciphertext_raw, $encryption_key, true);
	        $encryption= $iv.$hmac.$ciphertext_raw;
	        $encrypted_data = base64_encode($encryption);
            $result['status'] = 1;
            $result['msg'] = 'Data Ready';
            $result['encrypted_data'] = $encrypted_data;
        }
        return $result;        
    }

    /**
     * Encrypting the payload and env_key array for rest service
     * @author PRASANNA
     * @param type $payload_array
     * @param type $env_key_array
     * @return type
     */
    public function app_data_encryption($payload_array,$env_key_array=[]){
        $payload_arr = [];
        $payload=bin2hex(json_encode($payload_array));
        $payload_value=$this->encrypt($payload);
        $payload_arr['payload'] = $payload_value;
        $payload_arr['hash'] = $payload;
        if(!empty($env_key_array)){
        $env_key=bin2hex(json_encode($env_key_array));
        $env_key_value=$this->encrypt($env_key);
        $payload_arr['env_key'] = $env_key_value;
        }
        //return json_encode($payload_arr);
        return $payload_arr;
    }
    /**
     * Encrypting a string
     * @author PRASANNA
     * @param type $parameter
     * @param type $encrypt_format
     * @param type $front_add
     * @param type $back_add
     * @return type
     */
    public function encrypt($parameter,$encrypt_format=1,$front_add=5,$back_add=5)
    {
        $hex_string=bin2hex($parameter); //convert in to hex 
        $character_array=str_split($hex_string); // split each character in the hex
        $encrypted_string='';
        foreach ($character_array as $char) {
           $encrypted_string.=bin2hex($char); //convert each character in to hex
        }
        $front_add_num=rand(pow(10, $front_add-1), pow(10, $front_add)-1); //add number before
        $back_add_num=rand(pow(10, $back_add-1), pow(10, $back_add)-1); //add number after
        return $front_add_num."".$encrypted_string."".$back_add_num;
    }
    /**
     * Decrypt the string
     * @author PRASANNA
     * @param type $parameter
     * @param type $encrypt_format
     * @param type $front_add
     * @param type $back_add
     * @return type
     */
    public function decrypt($parameter,$encrypt_format=1,$front_add=5,$back_add=5)
    {
        
       try{ 
        $parameter = substr($parameter,$front_add,-$back_add);
        //echo $parameter;
        $encrypted_string_array=str_split($parameter, 2);
        $encrypted_string='';
        log_message("debug", "==========desrypt===============".json_encode($encrypted_string_array));
        foreach ($encrypted_string_array as $char) {
          if (ctype_xdigit($char)) {  
           if (strlen($char) % 2 == 0) {   
              $encrypted_string.=hex2bin($char);
           }
          }
        }
        if (ctype_xdigit($encrypted_string) && strlen($encrypted_string) % 2 === 0) {
            $hash_string = hex2bin($encrypted_string);
        }  else {
            // Handle invalid input gracefully
              $hash_string = null; // or assign a default value
              // Optionally log the error for debugging purposes
        }
        $response_decrypt[0]=$hash_string;
        //echo md5($response_decrypt[0]);
        
        $param_string = json_decode(hex2bin($hash_string), true);
        $response_decrypt[1]=$param_string;
        return $response_decrypt;
       } catch(Exception $ex){
           return null;
           log_message("debug", "Error in  Encryption_lib/decrypt::".json_encode($ex));
           str_to_file("Error occured in Encryption_lib/decrypt::".json_encode($ex));
       }
    }
    /**
     * Decrypts the given parameter, which is expected to be a hexadecimal string
     * with a random number added at the beginning and end.
     *
     * The function first extracts the actual encrypted string from the parameter.
     * Then, it decrypts the string by converting it from hexadecimal to binary.
     *
     * If the decryption fails, the function returns null and logs an error.
     *
     * @param string $parameter The parameter to be decrypted.
     * @param int $encrypt_format The encryption format to use. Default is 1.
     * @param int $front_add The number of characters to add at the beginning.
     * @param int $back_add The number of characters to add at the end.
     *
     * @return array|null An array containing the decrypted string and the
     *                    decrypted JSON object, or null if decryption fails.
     * @author Durga Prasad
     * @date 13-03-2025
     */
    public function stb_emi_decrypt($parameter, $encrypt_format = 1, $front_add = 5, $back_add = 5)
    {
        try {
            if (empty($parameter) || strlen($parameter) <= ($front_add + $back_add)) {
                log_message("error", "Invalid parameter length in decrypt function.");
                return null;
            }

            $parameter = substr($parameter, $front_add, -$back_add);
            if ($parameter === false || empty($parameter)) {
                log_message("error", "Parameter extraction failed in decrypt function.");
                return null;
            }

            $encrypted_string_array = str_split($parameter, 2);
            $encrypted_string = '';

            log_message("debug", "==========decrypt==============" . json_encode($encrypted_string_array));

            foreach ($encrypted_string_array as $char) {
                if (ctype_xdigit($char) && strlen($char) % 2 === 0) {   
                    $encrypted_string .= hex2bin($char);
                }
            }

            if (empty($encrypted_string)) {
                log_message("error", "Decryption resulted in an empty string.");
                return null;
            }
            if (ctype_xdigit($encrypted_string) && strlen($encrypted_string) % 2 === 0) {
                $hash_string = hex2bin($encrypted_string);
            }  else {
                // Handle invalid input gracefully
                  $hash_string = null; // or assign a default value
                  // Optionally log the error for debugging purposes
            }

            if ($hash_string === false) {
                log_message("error", "hex2bin conversion failed.");
                return null;
            }

            $response_decrypt[0] = $hash_string;
            $param_string = json_decode($hash_string, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                log_message("error", "JSON decode failed: " . json_last_error_msg());
                return null;
            }

            $response_decrypt[1] = $param_string;
            return $response_decrypt;

        } catch (Exception $ex) {
            log_message("error", "Error in Encryption_lib/decrypt: " . json_encode($ex->getMessage()));
            return null;
        }
    }

    /**
     * Decrypt the encrypted payload and return the payload in array format
     * @author PRASANNA
     * @param array $arr_post
     * @return array|string
     */
    public function checkPayload($arr_post){
        $raw_payload = isset($arr_post['payload'])?$arr_post['payload']:'';
        $hash_key = isset($arr_post['hash'])?$arr_post['hash']:'';
        
        $payload = '';
        if($raw_payload != ''){
            $payload_response_array=$this->decrypt($raw_payload);
            $hash_value=$payload_response_array[0];
            
            if($hash_value == $hash_key){
                $payload = $payload_response_array[1];
            }
        }

        return $payload;
    }

    /**
     * Decrypt the encrypted payload and return the payload in array format for chMovies API
     * @author Satya
     * @param array $arr_post
     * @return array|string
     */
    public function checkPayload_chMovies($arr_post){
        $raw_payload = isset($arr_post['payload'])?$arr_post['payload']:'';        
        $payload = '';
       
        if($raw_payload != ''){
            $payload_response_array=$this->decrypt($raw_payload);
            $payload = $payload_response_array[1];
        }
         
        return $payload;
    }
    /**
     * Encrypt the  payload  for chMovies API
     * @author Satya
     * @param type $payload_array
     * @return type
     */
    public function app_data_encryption_chMovies($payload_array,$env_key_array=[]){
        $payload_arr = [];
        $payload=bin2hex(json_encode($payload_array));
        $payload_value=$this->encrypt($payload);
        $payload_arr['payload'] = $payload_value;
        return $payload_arr;
    }
}
