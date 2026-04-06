<?php
/**
 * Dashboard
 Author : Ramesh 
 */
class Dashboard extends CI_Controller
{
    
    public function __construct()
    {
        parent::__construct();       
    }
    
	 public function index(){
	 $data = array('title'    => 'Ezybill.net | Selfcare | Login',
             'content'  => 'selfcare/content/login',
        );
	$this->load->view('selfcare/common/inner-template.php', $data);
	 }
	 
	   
}