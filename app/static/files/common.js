var chat_messages={};
var ws;
var ws_timeout=null;
var player;

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

/*
  Change characheristics view: absolute or as modifier
 */
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

function render_chars(){
  for( var mod in player['mods']){
    var n = Math.floor((player['mods'][mod]-10.0)/2);
    set_value('mod_'+mod, n+' ('+player['mods'][mod]+')');
  }
}

function push_to_str(str,x){

}
function render_equipmets(){
  var
  for (var i = player['equipmets'].length - 1; i >= 0; i--) {
    player['equipmets'][i]
  }
}

function char_plus(mod){
  player['mods'][mod] += 1;
  ws.send(secret+': mod '+mod+'='+player['mods'][mod]);
}

function char_minus(mod){
  player['mods'][mod] += 1;
  ws.send(secret+': mod '+mod+'='+player['mods'][mod]);
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
  render_chars();
  render_equipmets();
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
window.onload = function(){

  try_connect();

  if(typeof(dnd_init)==='function'){
    dnd_init();
  }
}
