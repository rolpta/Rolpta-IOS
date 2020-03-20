//loads a viewcontroller e.g. home
var vc_info={};
var vc_count=0;

var vc_css;
var doc;
var vcparams;


function loadvc(ovc) {

  vc=ovc.split('?')[0];
  vcparams='?'+ovc.split('?')[1];


  response=raise_event('loadvc',{vc:vc});

  if(response!==false) {
    //fetch vc from event
    vc=response.vc;
  }

  if(vc=='' || vc==false) {return false;}



  vc_count++;

  resetvc(vc);

  root="app";

  if(vc.indexOf('dist/')!=-1) {
  //use dist
  s=vc.split('/');
  s.shift();
  vc=s.join('/');
  root="dist";
  }

  //console.log(vc);

  if(vc.indexOf('/')==-1) {
    folder=file=vc;
  } else {
    s=vc.split('/');
    file=s[s.length-1];

    s.pop();
    folder=s.join('/');
  }

  //root= vc.indexOf('dist/')==-1 ? "app" : "dist";


  html=root+"/pages/" + folder + "/" + file + ".html";


  getvc(html);
}

//after loading json and html
function finalizevc() {

//close sidenav in case it is opened
$('.sidenav').sidenav('close');

//hide map
try {
google_map.hide();
} catch(e) {}

//get doc
doc = new DOMParser().parseFromString(vc_info.html, 'text/html');

render_title();

vc_render_css();

vc_render_html();

vc_render_js();

}

function render_title() {
  if (typeof doc.title !== 'undefined') {
    $('#titlebar').html(doc.title);
  }

}

function vc_render_css() {

  //remove any css file in dom
  if(vc_css!='') {
    $("link[href='" + vc_css +  "']").remove();
    vc_css='';
  }

  link=doc.body.getAttribute('css');

  if(link==null || link.length==0) {return};

  vc_css=asset(link);

  $('<link rel="stylesheet" type="text/css" href="'+vc_css+'" />').appendTo("head");
}


function vc_render_html() {

if (typeof doc.body.getAttribute('class') !== 'undefined') {
  marker=doc.body.getAttribute('class');
} else {
  marker='';
}

if (typeof doc.body.getAttribute('style') !== 'undefined') {
  marker2=doc.body.getAttribute('style');
} else {
  marker2='';
}

//login redirect
if (typeof doc.body.getAttribute('login_redir') !== 'undefined') {
  loginredir=doc.body.getAttribute('login_redir');
  if(loginredir) {
    login_redirect(loginredir);
  }
}


//determine whether to show back button or not
if (typeof doc.body.getAttribute('back_btn') !== 'undefined' && (doc.body.getAttribute('back_btn')=='1' || doc.body.getAttribute('back_btn')=='true')) {
  $('#back_btn').show();
} else {
  $('#back_btn').hide();
}

//floating back button
if (typeof doc.body.getAttribute('back_btn_float') !== 'undefined' && (doc.body.getAttribute('back_btn_float')=='1' || doc.body.getAttribute('back_btn_float')=='true')) {
  $('#back_btn_float').show();
} else {
  $('#back_btn_float').hide();
}

if (typeof doc.body.getAttribute('back_btn_menu') !== 'undefined' && (doc.body.getAttribute('back_btn_menu')=='1' || doc.body.getAttribute('back_btn_menu')=='true')) {
  $('.sidenav-trigger').hide();
  $('.sidenav-back').show();
} else {
  $('.sidenav-trigger').show();
  $('.sidenav-back').hide();
}

//floating location button
if (typeof doc.body.getAttribute('loc_btn_float') !== 'undefined' && (doc.body.getAttribute('loc_btn_float')=='1' || doc.body.getAttribute('loc_btn_float')=='true')) {
  $('#loc_btn_float').show();
} else {
  $('#loc_btn_float').hide();
}

//show nav logo
if (typeof doc.body.getAttribute('show_nav_logo') !== 'undefined' && (doc.body.getAttribute('show_nav_logo')=='1' || doc.body.getAttribute('show_nav_logo')=='true')) {
  $('.navlogo').show();
  $('.titlebar').hide();
} else {
  $('.navlogo').hide();
  $('.titlebar').show();
}


//hide support nav
if (typeof doc.body.getAttribute('hide_support_nav') !== 'undefined' && (doc.body.getAttribute('hide_support_nav')=='1' || doc.body.getAttribute('hide_support_nav')=='true')) {
  $('.support_nav').hide();
} else {
  $('.support_nav').show();
}

//hide_footer_nav
if (typeof doc.body.getAttribute('hide_footer_nav') !== 'undefined' && (doc.body.getAttribute('hide_footer_nav')=='1' || doc.body.getAttribute('hide_footer_nav')=='true')) {
  $('.footer_nav').hide();
} else {
  $('.footer_nav').show();
}


//set body marker
$('body').attr('class',marker);

$('body').attr('style',marker2);

$(window).scrollTop(0);

$('body-wrapper').html(doc.body.innerHTML);

//set footer menu
$('.footer_nav_lnk').removeClass('active');
try {
  $('#footer_nav_' + vc_info.vc).addClass('active');
} catch (e) {
  void(0);
}

//initiate select
$('select').not(".select").formSelect();

//modal
$('.modal').modal();

//date picker
$('.datepicker').datepicker();

//timepicker
$('.timepicker').timepicker();

//star rating
$('.rating').each(function() {
  $(this).addRating();
});

//lazy loader
$("img.lazy").lazyload();

}

//get js path
function vc_render_js() {
  link=doc.body.getAttribute('js');

  if(link==null || link.length==0) {return};



//js path
vc_info.js=asset(link);

loadjs(vc_info.js);
}


function resetvc(vc) {

//reset applet
applet = new function() {
};

applet_setup();

//reset info
vc_info={'vc':vc,'json':'',html:'',css:'',js:'',state:0};
}

//load a vc component
function getvc(html) {
  $.ajax({
    url: html,
    dataType: "html",
    cache: false,
    success: function(data) {
      vc_info.html=data;
      vc_info.state++;
      finalizevc();
    }
  }).fail(function(jqXHR, textStatus, errorThrown) {
    console.log('Unable to load html : '+vc_info.vc);
  });

}
