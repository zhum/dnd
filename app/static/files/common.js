var chat_messages={};
var ws;
var ws_timeout=null;
var player;

function set_html(id,value){
  var el = document.getElementById(id)
  if(el){
    el.innerHTML = value;
  }
}

function get_html(id){
  var el = document.getElementById(id)
  if(el){
    return el.innerText;
  }
  return null;
}

function get_value(id){
  var el = document.getElementById(id)
  if(el){
    return el.value;
  }
  return null;
}

function get_int_value(id){
  var v = get_value(id);
  if(typeof v === 'object' || typeof v === 'undefined' || v=='')
    return Number.NaN;
  return Number(v);
}
/*
  Change characheristics view: absolute or as modifier
function toggle_char_edit(){
  var el = document.querySelector('[data-char-edit]');
  var mod = el.getAttribute('data-char-edit');
  if(mod=='view'){
    el.innerHTML='<i class="iw-eye"></i>';
    el.setAttribute('data-char-edit','edit');
  }
  else{    
    el.innerHTML='<i class="iw-edit"></i>';
    el.setAttribute('data-char-edit','view');
  }
  document.querySelectorAll('[data-char-plus]').forEach(function(el){
    el.classList.toggle('mui--hide');
  });
  document.querySelectorAll('[data-char-minus]').forEach(function(el){
    el.classList.toggle('mui--hide');
  });
  render_chars();
}
 */

/*
  
function toggle_equipment_edit(){
  var el = document.querySelector('[data-equipment-edit]');
  var mod = el.getAttribute('data-equipment-edit');
  if(mod=='view'){
    el.innerHTML='<i class="iw-eye"></i>';
    el.setAttribute('data-equipment-edit','edit');
  }
  else{    
    el.innerHTML='<i class="iw-edit"></i>';
    el.setAttribute('data-equipment-edit','view');
  }
  document.querySelectorAll('[data-equipment-plus]').forEach(function(el){
    el.classList.toggle('mui--hide');
  });
  document.querySelectorAll('[data-equipment-minus]').forEach(function(el){
    el.classList.toggle('mui--hide');
  });
  render_chars(mod==='view'); // previous value!
}
 */

/*
  
function toggle_weapon_edit(){
  var el = document.querySelector('[data-weapon-edit]');
  var mod = el.getAttribute('data-weapon-edit');
  if(mod=='view'){
    el.innerHTML='<i class="iw-eye"></i>';
    el.setAttribute('data-weapon-edit','edit');
  }
  else{    
    el.innerHTML='<i class="iw-edit"></i>';
    el.setAttribute('data-weapon-edit','view');
  }
  document.querySelectorAll('[data-weapon-plus]').forEach(function(el){
    el.classList.toggle('mui--hide');
  });
  document.querySelectorAll('[data-weapon-minus]').forEach(function(el){
    el.classList.toggle('mui--hide');
  });
  render_weapons(mod==='view'); // previous value!
}
*/
function render_chars(){
  for( var mod in player['mods']){
    var n = Math.floor((player['mods'][mod]-10.0)/2);
    set_html('mod_'+mod, n+' ('+player['mods'][mod]+')');
  }
}

function push_to_eq(str,x,keys_visible=false){
  //*** columns version
  // str += '<div class="mui-row mui--divider-bottom equipment"><div class="mui-col-xs-3 mui--text-left">'+
  //  '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'eq_plus\',\'eq_minus\',\'eq_set\',\''+x['id']+'\'));">'+
  //   x['name']+'</a></div><span class="mui-col-xs-3">'+
  //   x['description']+'</span>';
  //   str += '<span class="mui-col-xs-1">'+x['count']+
  //   '</span></div>';
  //   
  //*** flex version
  str += '<span class="mui--text-left">'+
   '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'eq_plus\',\'eq_minus\',\'eq_set\',\''+x['id']+'\'));">'+
    x['name']+'</a><span> ('+x['count']+'); </span></span>';
  return str;
}

function render_equipments(mod=false){
  var eq_html='<div class="dnd-flex-row">';
  Object.keys(player['equipments']).sort().forEach(function(i) {
    eq_html = push_to_eq(eq_html, player['equipments'][i], mod);
  });
  set_html('equipment',eq_html+'</div>');
}

function push_to_weap(str,x,keys_visible){
  // str += '<div class="mui-row mui--divider-bottom weapon"><div class="mui-col-xs-2 mui--text-left">'+
  //   x['name']+'</div><div class="mui-col-xs-5">'+
  //   x['description']+'</div>';
  //   str += '<div class="mui-col-xs-1">'+x['count']+
  //   '</div><div class="mui-col-xs-1">'+x['dice']+'d'+x['of_dice']+
  //   '</div><div class="mui-col-xs-3">'+
  //     '<span class="dnd-btn dnd-btn--small dnd-btn--accent'+(keys_visible ? '' : ' mui--hide')+'"'+
  //     ' data-weapon-plus="'+x['id']+'" onclick="weapon_plus('+x['id']+');">'+
  //     '<i class="iw-up"></i>'+
  //     '</span><span class="dnd-btn dnd-btn--small dnd-btn--accent'+(keys_visible ? '' : ' mui--hide')+'"'+
  //     ' data-weapon-minus="'+x['id']+'" onclick="weapon_minus('+x['id']+');">'+
  //     '<i class="iw-down"></i>'+
  //   '</span></div></div>';
  str += '<div class="mui-row mui--divider-bottom weapon"><div class="mui-col-xs-2 mui--text-left">'+
    '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'weap_plus\',\'weap_minus\',\'weap_set\',\''+x['id']+'\'));">'+
    x['name']+'</a></div>'+
    '<div class="mui-col-xs-1">'+x['count']+'</div><div class="mui-col-xs-5 mui--divider-left">'+
    x['description']+
    '</div><div class="mui-col-xs-1 mui--divider-left">'+x['dice']+'d'+x['of_dice']+
    '</div></div>';
  return str;
}

function render_weapons(mod=false){
  var weap_html='';
  //for(var i in player['weapons']){
  Object.keys(player['weapons']).sort().forEach(function(i) {
    weap_html = push_to_weap(weap_html, player['weapons'][i], mod);
  });
  set_html('weapons',weap_html);
}

// function weapon_plus(weap){
//   player['weapons'][weap]['count'] += 1;
//   ws.send(secret+': weap '+weap+'='+JSON.stringify(player['weapons'][weap]));
// }

// function weapon_minus(weap){
//   player['weapons'][weap]['count'] -= 1;
//   ws.send(secret+': weap '+weap+'='+JSON.stringify(player['weapons'][weap]));
// }

function set_num(value,id){
  var v = Number(value);
  if(Number.isNaN(v)){return;}
  set_html(id,v);
}

function render_player(data){
  //alert(data);
  set_html('player-name', data.name);
  set_html('player-class', data.klass);
  set_html('player-race', data.race);
  set_html('hp', data.hp);
  set_html('max-hp', data.max_hp);
  set_html('player-exp', data.experience);
  set_html('ccoins', data.coins[0]);
  set_html('scoins', data.coins[1]);
  set_html('gcoins', data.coins[2]);
  set_html('ecoins', data.coins[3]);
  set_html('pcoins', data.coins[4]);
  set_html('total-gold', (data.coins[0]+data.coins[1]*10+data.coins[2]*100+
                           data.coins[3]*50+data.coins[4]*1000)/100);
  for( var ch in data.chars){
    set_html('ch_'+ch, data.chars[ch]);
  }
  set_html('ch_hit_dice_full',data.chars.hit_dice+' K'+data.chars.hit_dice_of)

  render_chars();
  
  // var el = document.querySelector('[data-equipment-edit]');
  // var mod = el.getAttribute('data-equipment-edit');
  render_equipments();//mod==='edit');
  
  // el = document.querySelector('[data-weapon-edit]');
  // mod = el.getAttribute('data-weapon-edit');
  render_weapons();//mod==='edit');
  
}

function render_chat(from=''){
  var el = document.getElementById('chat');
  if(el){
    from='';
  }
  else{
    el = document.getElementById('chat'+from);
  }
  if(el){
    render_chat_full(from);
  }
  var ind = document.getElementById('chat-indicator'+from);
  if(ind){
    ind.classList.remove('no-messages');
    ind.classList.add('new-message');
  }
}

function render_chat_full(from=''){
  var chat_text='<div class="mui-container-fluid">';
  var name_style;
  var text_style;
  var read;
  var list = chat_messages[from];
  for (var i = list.length - 1; i >= 0; i--) {
    name_style = list[i]['from']=='MASTER' ? 'master-name' : 'my-name';
    text_style = list[i]['from']=='MASTER' ? 'master-message' : 'my-message';
    read = list[i]['read']=='yes' ? '' : '<span class="new-message">*</span>';
    chat_text = chat_text+'<div class="mui-row"><div data-msgid="'+list[i]['id']+'" class="mui-col-xs-2 '+name_style+'">'+
      list[i]['from']+': </div><div class="mui-col-xs-10 '+text_style+'">'+
      list[i]['text']+'</div></div>';
  }
  chat_text = chat_text+'</div>';
  set_html('chat'+from,chat_text);
}

function toggle_item(item){
  var el = document.getElementById(item);
  if(el){
    el.classList.toggle('mui--hide');
  }
}


/************************************************************
   Modals
*************************************************************/

var modal_function;
var modal_arg;

function intModal(f,id) {
  // initialize modal element
  var modalEl = document.createElement('div');
  modalEl.style.width = '95%';
  modalEl.style.height = '3em';
  modalEl.style.margin = '50% auto';
  modalEl.style.padding = '5px 5px';
  modalEl.style.backgroundColor = '#fff';
  modalEl.innerHTML = '<form><span>Число: </span><input id="qq" type="text"></input><button onClick="modalEnter();">OK</input></form>';
  modal_function = f;
  //modal_arg = id;
  // var el = modalEl.children[0];
  // el.setAttribute('data-function',f);

  // show modal
  mui.overlay('on', modalEl);
}

function modalEnter(){
  // var el = document.getElementById('qq');
  // var f = el.getAttribute('data-function');
  modal_function(document.getElementById('qq').value,modal_arg);
  mui.overlay('off');
}

/*!!!!!!!!!!!!!!!!!*/
function formModal(form) {
  // initialize modal element
  var modalEl = document.createElement('div');
  modalEl.style.width = '95vw';
  modalEl.style.height = '3em';
  modalEl.style.margin = '50vh auto';
  modalEl.style.padding = '5px 5px';
  modalEl.style.backgroundColor = '#fff';
  modalEl.innerHTML = form;
  // modal_function = f;
  // modal_arg = arg;
  // var el = modalEl.children[0];
  // el.setAttribute('data-function',f);

  // show modal
  mui.overlay('on', modalEl);
}

function formEnter(){
  modal_function(document.getElementById('qq').value,modal_arg);
  mui.overlay('off');
}

function xover(){
  mui.overlay('off');
}

function overForm3(f1,f2,f3,arg){
  return '<form class="mui--text-center"><div class="dnd-flex-row fullwidth">'+
    '<a class="dnd-btn dnd-btn--primary dnd-flex-grow1" href="#" onclick="'+f1+"('"+arg+"');xover();\"> + </a>"+
    '<a class="dnd-btn dnd-btn--primary dnd-flex-grow1" href="#" onclick="'+f2+"('"+arg+"');xover();\"> - </a>"+
    '<input type="text" class="dnd-flex-grow2" id="over_value"></input>'+
    '<a class="dnd-btn dnd-btn--primary dnd-flex-grow1" href="#" onclick="'+f3+"('"+arg+"');xover();\">OK</a>"+
  '</div></form>'
}

// function overForm5(fp1,fp5,fm1,fm5,fs,arg){
//   return '<form class="mui--text-center">'+
//     '<a class="dnd-btn dnd-btn--primary" href="#" onclick="'+f1+"('"+arg+"');xover();\">+</a>"+
//     '<a class="dnd-btn dnd-btn--primary" href="#" onclick="'+f2+"('"+arg+"');xover();\">-</a>"+
//     '<input type="text" width="3" id="over_value"></input>'+
//     '<a class="dnd-btn dnd-btn--primary" href="#" onclick="'+f3+"('"+arg+"');xover();\">OK</a>"+
//   '</form>'
// }

/************************************************************
   Connections
*************************************************************/
function send_msg_to_chat(inputid=''){
  if(inputid==''){
    inputid = "msg"
  }
  var el = document.getElementById(inputid);
  var receiver;
  if(el.getAttribute('data-for')==null){
    receiver = '';
  }
  else{
    receiver = '"for":"'+el.getAttribute('data-for')+'", ';
  }
  ws.send(secret+': message={'+receiver+'"text":"'+el.value+'"}');
  el.value = '';
}

function mark_connection(on){
  var el = document.getElementById('connected');
  if(el){
    if(on=='yes'){
      el.classList.add('connected'); el.classList.remove('disconnected');
    }
    else{
      el.classList.remove('connected'); el.classList.add('disconnected');
    }
  }
}

function try_connect(){
  ws = new WebSocket('ws://' + window.location.host+player_str);// + window.location.pathname);
  if(ws){
    clearTimeout(ws_timeout);
    ws.onopen    = function(){
      mark_connection('yes');
      ws.send(secret+': hello');
      if(on_websocket_open){
        on_websocket_open(ws);
      }
    };
    ws.onclose   = function(){
      mark_connection('no');
      ws_timeout = setTimeout(try_connect,2000);
    }
    ws.onerror   = function(){
      mark_connection('no');
      ws_timeout = setTimeout(try_connect,2000);
    }
    ws.onmessage = function(m) {
      //alert(m.data);
      var msg = JSON.parse(m.data);
      if(msg['master']){
        render_master(msg['master']);
      }
      else if(msg['player']){
        player = msg['player'];
        render_player(player);
      }
      else if(msg['chat']){ // new message!
        var id='';
        if('from' in msg){
          id = msg['from'];
        }
        if(!chat_messages[id]){
          chat_messages[id]=[];
        }
        chat_messages[id].push(msg['chat']);
        render_chat(id);
      }
      else if(msg['chat_history']){
        var id='';
        if('from' in msg){
          id = msg['from'];
        }
        chat_messages[id] = msg['chat_history'];
        render_chat(id);
      }
    }
  }
}
/*  INIT  */
window.onload = function(){

  try_connect();

  if(typeof(dnd_init)==='function'){
    dnd_init();
  }
}
