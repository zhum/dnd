var chat_messages=[];
var ws;

function set_value(id,value){
  var el = document.getElementById(id)
  if(el){
    el.innerHTML = value;
  }
}

function get_value(id,value){
  var el = document.getElementById(id)
  if(el){
    return el.innerText;
  }
  return null;
}

function render_player(data){
  //alert(data);
  set_value('player-name', data.name);
  set_value('player-class', data.klass);
  set_value('player-race', data.race);
  set_value('hp', data.hp);
  set_value('ccoins', data.coins[0]);
  set_value('scoins', data.coins[1]);
  set_value('gcoins', data.coins[2]);
  set_value('ecoins', data.coins[3]);
  set_value('pcoins', data.coins[4]);
  set_value('total-gold', (data.coins[0]+data.coins[1]*10+data.coins[2]*100+
                           data.coins[3]*50+data.coins[4]*1000)/100);
  for( var ch in data.chars){
    set_value('ch_'+ch, data.chars[ch]);
  }
  set_value('ch_hit_dice_full',data.chars.hit_dice+' K'+data.chars.hit_dice_of)
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
  var ind = document.getElementById('chat_indicator'+from);
  if(ind){
    el.classList.add('new_message');
  }
}

function render_chat_full(from=''){
  var chat_text='<div class="mui-container-fluid">';
  var name_style;
  var text_style;
  var read;
  for (var i = chat_messages.length - 1; i >= 0; i--) {
    name_style = chat_messages[i]['from']=='MASTER' ? 'master-name' : 'my-name';
    text_style = chat_messages[i]['from']=='MASTER' ? 'master-message' : 'my-message';
    read = chat_messages[i]['read']=='yes' ? '' : '<span class="new-message">*</span>';
    chat_text = chat_text+'<div class="mui-row"><div data-msgid="'+chat_messages[i]['id']+'" class="mui-col-xs-2 '+name_style+'">'+
      chat_messages[i]['from']+': </div><div class="mui-col-xs-10 '+text_style+'">'+
      chat_messages[i]['text']+'</div></div>';
  }
  chat_text = chat_text+'</div>';
  set_value('chat'+from,chat_text);
}

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

window.onload = function(){
  var show = function(el){}
  // function(el){
  //   return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
  // }(document.getElementById('msgs'));

  ws           = new WebSocket('ws://' + window.location.host+player_str);// + window.location.pathname);
  ws.onopen    = function(){
    //ws.send(secret+': get_chat');
    on_websocket_open(ws);
  };
  ws.onclose   = function()
  { }
  ws.onmessage = function(m) {
    //alert(m.data);
    var msg = JSON.parse(m.data);
    if(msg['master']){
      render_master(msg['master']);
    }
    else if(msg['player']){
      render_player(msg['player']);
    }
    else if(msg['chat']){ // new message!
      chat_messages.push(msg['chat']);
      render_chat(msg['from']);
    }
    else if(msg['chat_history']){
      chat_messages = msg['chat_history'];
      render_chat(msg['from']);
    }
  };
}
