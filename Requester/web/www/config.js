//app key
var app_key = "requester";

var use_map = true;

//paystack key
var paystack_key='pk_test_322bcff1c8dc2ce67e0af40f507dfd450ba4a61a';

//google map key
//var map_key='AIzaSyCd0QhvdM_Fe5WMVPtPO3jEx09E5VYvgyI';
var map_key='AIzaSyC3pajoIzkPZ7L0Z_rNduBy8fuvJgwlatY';



//base api url
if(location.href.indexOf('dev.')==-1) {
  api_base_url = 'https://api.rolpta.afrk.co/';
  api_base_url = 'https://zapi.rolpta.com/';
} else {
  api_base_url = 'https://api.rolpta.test/';
}

//user dashboard
user_dashboard = 'dashboard';

//home page
user_home = 'home';

//map of the orders pages by state
var order_map={
	"8":"dispatchers/track",
	"9":"rate",
	"10":"rate/cancel"
};
