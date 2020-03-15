var chat_messages={};
var ws;
var ws_timeout=null;
var flash_timeout=null;
var flash_timeout_ms = 3000;
var player;
var prefs={};
var fighters=[];
var fight={};
var dam_types=['none', 'дрб.', 'кол.', 'руб.'];
var f_steps=['всё тихо...','кидайте инициативу!','битва!','битва окончена'];

function get_over_value(def=1){
  var v = get_int_value('over_value');
  if(Number.isNaN(v))
    v = def;
  return v;    
}

function show_message(txt){
  var el = document.getElementById('short-flash');
  if(el){
    el.classList.remove('short-flash-green');
    el.innerHTML = txt;
    el.classList.add('short-flash-green');
  }
}

function txt_or_empty(txt){
  return txt==null ? '' : txt;
}

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

function set_attr(id,name,value){
  var el = document.getElementById(id);
  if(el){
    el.setAttribute(name,value);
  }
}

function get_attr(id,name){
  var el = document.getElementById(id);
  if(el){
    return el.getAttribute(name);
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

function render_chars(){
  for( var mod in player['mods']){
    var n = Math.floor((player['mods'][mod][0]-10.0)/2);
    set_html('mod_'+mod, n+' ('+player['mods'][mod][0]+')');
    set_html(
      'mod_prof_'+mod,
      player['mods'][mod][1]=='1' ?
        '<i class="icon-ok-circle"></i>' :
        '<i class="icon-circleloaderempty"></i>'
    );
    set_attr('mod_prof_'+mod, 'prof', player['mods'][mod][1]);
  }
}

function push_to_arm(str,x,id,keys_visible=false){
  str += '&nbsp;<span class="mui--text-left mui--divider-left">'+
    '<i class="icon-ok-'+(x['wear'] ? 'sign' : 'circle')+'" onclick="wear_armor('+id+')"></i>'+
    '<span> '+x['count']+'</span>'+
    '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'arm_plus\',\'arm_minus\',\'arm_set\','+id+'));">'+
     x['name']+'</a></span>';
  return str;
}

function render_armors(mod=false){
  var arm_html='<div class="dnd-flex-row">';
  //Object.keys(player['armors']).sort().forEach(function(i) {
  for (var i in player['armors']) {
    arm_html = push_to_arm(arm_html, player['armors'][i], i, mod);
  };
  set_html('armor',arm_html+'</div>');
}

function get_spell_help(id){
  var sp = player.spells[id];
  return '<p>Наложение: '+txt_or_empty(sp.spell_time)+'</p>'
    +'<p>Длительность: '+txt_or_empty(sp.lasting_time)+'</p>'
    +'<p>Дистанция: '+txt_or_empty(sp.distance)+'</p>'
    +'<p>Компоненты: '+txt_or_empty(sp.components)+'</p>'
    +txt_or_empty(sp['description']);
}
function push_to_spells(str,x,id,keys_visible=false){//icon-info-sign
  str += '<div class="mui--divider-right mui--divider-bottom">'
    +  '<span class="circle-around" onclick="formModalHelp(spellFormHelp('+id+'))">&nbsp;?&nbsp;</span>'
    +  '<a class="dnd-btn'+(x['active'] ? ' dnd-btn--primary' : '')
    +    '" href="#" onclick="activate_spell('+id+')">'
    +    x['name']+'</a>&nbsp;'
    +  x['level']
    +  '&nbsp;<i class="icon-'+(x['ready'] ? 'ok-sign' : 'circleloaderempty')+'" onclick="ready_spell('+id+')"></i> '
    +'</div>';
  return str;
}

function render_spells(mod=false){
  var arm_html='';
  for (var i in player['spells']) {
    arm_html = push_to_spells(arm_html, player['spells'][i], i, mod);
  };
  set_html('spell-list',arm_html);
}

function push_to_thing(str,x,id,keys_visible=false){
  str += '<span class="mui--text-left">'+
   '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'thing_plus\',\'thing_minus\',\'thing_set\','+id+'));">'+
    x['name']+'</a><span> '+x['count']+'</span></span>';
  return str;
}

function render_things(mod=false){
  var thing_html='<div class="dnd-flex-row">';
  //Object.keys(player['thingors']).sort().forEach(function(i) {
  for (var i in player['things']) {
    thing_html = push_to_thing(thing_html, player['things'][i], i, mod);
  };
  //thing_html += '<a class="dnd-btn dnd-btn--primary" href="/buy?type=things">+</a>'
  set_html('things',thing_html+'</div>');
}

function push_to_weap(str,x,id,keys_visible){
  str += '<div class="mui-row mui--divider-bottom weapon">'
    +  '<div class="mui-col-xs-6 mui--text-left">'
    +    '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'weap_plus\',\'weap_minus\',\'weap_set\','+id+'));">'
    +      x['name']
    +    '&nbsp;'+x['damage']+'d'+x['damage_dice']+'('+dam_types[x['damage_type']]+')</a>'
    +  '</div>'
    +  '<div class="mui-col-xs-1">'+x['count']+'</div>'
    +  '<div class="mui-col-xs-5 mui--divider-left">'
    +    x['description']
    //'</div><div class="mui-col-xs-1 mui--divider-left">'+x['damage']+'d'+x['damage_dice']+'('+dam_types[x['damage_type']]+
    +  '</div>'
    +'</div>';
  return str;
}

function render_weapons(mod=false){
  var weap_html='';
  for(var i in player['weapons']){
  //Object.keys(player['weapons']).sort().forEach(function(i) {
    weap_html = push_to_weap(weap_html, player['weapons'][i], i, mod);
  };
  set_html('weapons',weap_html);
}

function render_skills(){
  var v;
  for(var i in player['skills']){
    v = player['skills'][i];
    set_html('skill_'+v['name'], '<i class="icon-'+(v['ready'] ? 'ok-circle' : 'circleloaderempty')+'"></i> '+v['mod']);
  }
  set_html('bad_stealth', player['bad_stealth'] ? '&nbsp;<i class="icon-exclamation-sign"></i>' : '')
}

function push_to_features(str,x,id,keys_visible){
  str += '&nbsp;<span class="mui--divider-left">'+
    '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'feature_plus\',\'feature_minus\',\'feature_set\','+id+'));">'+
    x['name']+'</a>&nbsp;'+x['count']+'('+x['max_count']+
    ')</span>';
  return str;
}

function render_features(mod=false){
  var features_html='';
  for(var i in player['features']){
    features_html = push_to_features(features_html, player['features'][i], i, mod);
  };
  set_html('features',features_html);
}

function render_savethrows(mod=false){
  set_html('savethrows1',player['savethrows1']);
  set_html('savethrows2',player['savethrows2']);
}


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
  set_html('total-weight', data.total_weight);
  for (var i = 1; i<=9; i+=1) {
    set_html('spells_'+i, data['spells_'+i])
  }
  for( var ch in data.chars){
    set_html('ch_'+ch, data.chars[ch]);
  }
  //set_html('ch_hit_dice_full',data.chars.hit_dice+' K'+data.chars.hit_dice_of)

  render_chars();
  
  // var el = document.querySelector('[data-equipment-edit]');
  // var mod = el.getAttribute('data-equipment-edit');
  render_armors();//mod==='edit');
  
  // el = document.querySelector('[data-weapon-edit]');
  // mod = el.getAttribute('data-weapon-edit');
  render_weapons();//mod==='edit');

  render_things();

  render_skills();

  render_features();

  render_savethrows();

  render_spells();

  render_bads();
  
}

function render_bads(){
  set_html('bads',player.bads);
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

function fight_step(s){
  s = parseInt(s);
  if(s<0 || s>3)
    s=0;
  return f_steps[s];
}

function render_fight(){
  var start_btn = document.getElementById('start-fight-btn');
  if(player){
    if(fight.fase==1){
      render_dice_roll();
    }
    else if(fight.fase==2){
      render_player_fight();
    }
    else{
      set_html('fight-list','.....');
    }
  }
  else{
    if(start_btn){
      if(fight.fase==0){
        start_btn.innerHTML = 'Roll initiative!';
      }
      else if(fight.fase==1){
        start_btn.innerHTML = 'Start fight!';
      }
      else if(fight.fase==2){
        start_btn.innerHTML = 'Stop fight!';
      }
      else{
        start_btn.innerHTML = 'New fight!';
      }
    }
  }
  set_html('fight-fase', fight_step(fight.fase));
}

function render_master_fight() {
  var header = '<div class="dnd-flex-cont fullwidth"><div class="dnd-flex-grow1">Name'+
      '</div><div class="dnd-5em dnd-flex-noresize center mui--divider-left">HP/MAX</div>'+
      '<div class="dnd-3em dnd-flex-noresize center mui--divider-left">Arm</div>'+
      '<div class="dnd-3em dnd-flex-noresize center mui--divider-left">In</div>'+
      '<div class="dnd-5em dnd-flex-noresize center mui--divider-left">Step</div></div>';
  var str = '';
  var off = '';
  var i=-1;
  var fighters_with_index = _.map(fighters,function(x){i+=1; return [x,i]});
  //  ^^^^ [[fighter1, 0], [fighter2,1],...]
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  _.forEach(fighters_with_index, function(info){
    var fighter = info[0];
    var i = info[1];
    var isf = fighter.is_fighter;
    add = 
      '<div class="dnd-flex-cont fullwidth">'+
        '<div class="dnd-1em'+(fight.fighter_index==i ? ' dnd-cur-fighter' : '')+'"></div>'+
        '<div class="dnd-flex-grow1 '+
        (isf ? (fighter.is_npc ? 'dnd-npc-fighter' : 'dnd-player-fighter') : 'dnd-off-fighter')+
        '">'+
        '<i class="icon-'+(isf ? 'circledelete' : 'fatundo')+'" onclick="'+(isf ? 'fighter_delete' : 'fighter_restore')+'('+i+')"></i>&nbsp;'+
        fighter.name+' ('+
        fighter.race+')</div><div class="dnd-5em dnd-flex-noresize center mui--divider-left">'+
          (fighter.is_npc ?
            '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_hp_plus\',\'f_hp_minus\',\'f_hp_set\','+i+'));">'
            : '')+
        fighter.hp+
          (fighter.is_npc ?
            '</a> / <a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_max_hp_plus\',\'f_max_hp_minus\',\'f_max_hp_set\','+i+'));">'
            : ' / ')+
        fighter.max_hp+
          (fighter.is_npc ? '</a>' : '')+
          '</div><div class="dnd-3em dnd-flex-noresize center mui--divider-left">'+
          (fighter.is_npc ?
            '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_ac_plus\',\'f_ac_minus\',\'f_ac_set\','+i+'));">'
            : '')+
        fighter.armor_class+
          (fighter.is_npc ? '</a>' : '')+
          '</div><div class="dnd-3em dnd-flex-noresize center mui--divider-left">'+
        (!fighter.is_npc && fight.fase==1 ?
          '<span class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_init_plus\',\'f_init_minus\',\'f_init_set\','+i+'));">'+
          fighter.initiative+'</span>' :
        fighter.initiative)+
          '</div><div class="dnd-5em dnd-flex-noresize center mui--divider-left">'+
          fighter.step_order+
          '&nbsp;<i class="icon-fastdown" onclick="fight_step_down('+i+')"></i>&nbsp;'+
          ' <i class="icon-fastup" onclick="fight_step_up('+i+')"></i>&nbsp;'+
        '</div>'+
      '</div>';
    if(isf){
      str += add;
    }
    else{
      off += add;
    }
  });
  set_html('fight-list',header+off+str);
}

function render_dice_roll(){
  set_html('fight-list','<div class="fullwidth mui--text-center"><input type="text" id="rolled-dice"></input><a href="#" class="dnd-btn" onClick="dice_rolled();">submit</a></div>');
}

function render_player_fight() {
  var header =
    '<div class="dnd-flex-cont fullwidth"><div class="dnd-1em"></div>'+
    '<div class="dnd-flex-grow1">Name</div>'+
    //'<div class="dnd-5em dnd-flex-noresize center mui--divider-left">HP/MAX</div>'+
    //'<div class="dnd-3em dnd-flex-noresize center mui--divider-left">Arm</div>'+
    //'<div class="dnd-3em dnd-flex-noresize center mui--divider-left">In</div>'+
    '<div class="dnd-5em dnd-flex-noresize center mui--divider-left">Step</div></div>';
  var str = '';
  var off = '';
  var i=-1;
  var fighters_with_index = _.map(fighters,function(x){i+=1; return [x,i]});
  //  ^^^^ [[fighter1, 0], [fighter2,1],...]
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  _.forEach(fighters_with_index, function(info){
    var fighter = info[0];
    var i = info[1];
    var isf = fighter.is_fighter;
    add = 
      '<div class="dnd-flex-cont fullwidth">'+
        '<div class="dnd-1em'+(fight.fighter_index==i ? ' dnd-cur-fighter' : '')+'"></div>'+
        '<div class="dnd-flex-grow1 '+
        (isf ? (fighter.is_npc ? 'dnd-npc-fighter' : 'dnd-player-fighter') : 'dnd-off-fighter')+
        '">'+
        fighter.name+' ('+
        fighter.race+')</div>'+
        //'<div class="dnd-5em dnd-flex-noresize center mui--divider-left">'+
          // (fighter.is_npc ?
          //   '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_hp_plus\',\'f_hp_minus\',\'f_hp_set\','+i+'));">'
          //   : '')+
        // fighter.hp+
        //   (fighter.is_npc ?
        //     '</a> / <a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_max_hp_plus\',\'f_max_hp_minus\',\'f_max_hp_set\','+i+'));">'
        //     : ' / ')+
        // fighter.max_hp+
        //   (fighter.is_npc ? '</a>' : '')+
        //   '</div><div class="dnd-3em dnd-flex-noresize center mui--divider-left">'+
        //   (fighter.is_npc ?
        //     '<a class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_ac_plus\',\'f_ac_minus\',\'f_ac_set\','+i+'));">'
        //     : '')+
        // fighter.armor_class+
        //   (fighter.is_npc ? '</a>' : '')+
        //   '</div><div class="dnd-3em dnd-flex-noresize center mui--divider-left">'+
        // (!fighter.is_npc && fight.fase==1 ?
        //   '<span class="dnd-btn dnd-btn--primary" href="#" onclick="formModal(overForm3(\'f_init_plus\',\'f_init_minus\',\'f_init_set\','+i+'));">'+
        //   fighter.initiative+'</span>' :
        // fighter.initiative)+
          // '</div>'+
        '<div class="dnd-5em dnd-flex-noresize center mui--divider-left">'+
          fighter.step_order+
          // '&nbsp;<i class="icon-fastdown" onclick="fight_step_down('+i+')"></i>&nbsp;'+
          // ' <i class="icon-fastup" onclick="fight_step_up('+i+')"></i>&nbsp;'+
        '</div>'+
      '</div>';
    if(isf){
      str += add;
    }
    else{
      off += add;
    }
  });
  set_html('fight-list',header+off+str);
}





function toggle_item(item){
  var el = document.getElementById(item);
  if(el){
    el.classList.toggle('mui--hide');
    ws.send(secret+': player/pref ui_'+item+'='+(el.classList.contains('mui--hide') ? '0' : '1'));
  }
}

function onoff_item(item,value){
  var el = document.getElementById(item);
  if(el){
    if(value=='1')
      el.classList.remove('mui--hide');
    else
      el.classList.add('mui--hide');
  }
}

//!!FIXME!
function apply_prefs(){
  for (var i in prefs) {
    value = prefs[i];
    if(i.substring(0,3)=='ui_'){
      onoff_item(i.substring(3),value)
    }
    // if(i=='ui_weapons'){
    //   onoff_item('weapons',value)
    // }
    // else if(i=='ui_armor'){
    //   onoff_item('armor',value)
    // }
    // else if(i=='ui_things'){
    //   onoff_item('things',value)
    // }
    // else if(i=='ui_fight'){
    //   onoff_item('fight',value)
    // }
    // else if(i=='ui_char'){
    //   onoff_item('char',value)
    // }
    // else if(i=='ui_skills'){
    //   onoff_item('skills',value)
    // }
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
  document.getElementById('mui-overlay').classList.remove('modal-form')
  mui.overlay('off');
}

/*!!!!!!!!!!!!!!!!!*/
function formModal(form) {
  // initialize modal element
  var modalEl = document.createElement('div');
  modalEl.innerHTML = form;

  // show modal
  mui.overlay('on', modalEl);
  //modalEl.classList.add = 'modal-form';
  document.getElementById('mui-overlay').classList.add('modal-form');
  document.getElementById('over_value').focus();
}

function formModalHelp(form) {
  // initialize modal element
  var modalEl = document.createElement('div');
  modalEl.innerHTML = form;

  // show modal
  mui.overlay('on', modalEl);
  modalEl.classList.add('align-vertical');
  document.getElementById('mui-overlay').classList.add('modal-help-form');
  document.getElementById('over_value').focus();
}

function formEnter(){
  modal_function(document.getElementById('qq').value,modal_arg);
  document.getElementById('mui-overlay').classList.remove('modal-form')
  mui.overlay('off');
}

function xover(classname='modal-form'){
  mui.overlay('off');
  var over = document.getElementById('mui-overlay');
  if(over){
    over.classList.remove(classname);
  }
}

function overForm3(f1,f2,f3,arg){
  return '<form class="mui--text-center"><div class="dnd-flex-row fullwidth">'+
    '<a class="dnd-btn dnd-btn--primary dnd-flex-grow1" href="#" onclick="'+f1+"('"+arg+"');xover();\"> + </a>"+
    '<a class="dnd-btn dnd-btn--primary dnd-flex-grow1" href="#" onclick="'+f2+"('"+arg+"');xover();\"> - </a>"+
    '<input type="text" autofocus class="dnd-flex-grow2" id="over_value" onkeydown="if(event.keyCode==13){'+f3+"('"+arg+"');xover();}\"></input>"+
    '<a class="dnd-btn dnd-btn--primary dnd-flex-grow1" href="#" onclick="'+f3+"('"+arg+"');xover();\">OK</a>"+
  '</div></form>'
}

function spellFormHelp(id){
  var str = '<div class="fullwidth">'
    +get_spell_help(id)
    +'<br><a class="dnd-btn dnd-btn--accent" href="#" onclick="xover('+"'modal-help-form'"+')";>Close</a>'
    +"</div>";
  return str;
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
  if(!player_active){
    console.log("skip connect!")
    return;
  }

  var proto = window.location.protocol.substr(0,5)=='https' ? 'wss' : 'ws'
  ws = new WebSocket(proto+'://' + window.location.host+player_str);// + window.location.pathname);
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
      if(msg['event']){
        show_message(msg['event']);
      }
      if(msg['master']){
        render_master(msg['master']);
      }
      if (msg['player']){
        player = msg['player'];
        render_player(player);
      }
      if (msg['prefs']){
        prefs = msg['prefs'];
        apply_prefs(prefs);
      }
      if (msg['chat']){ // new message!
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
      if (msg['chat_history']){
        var id='';
        if('from' in msg){
          id = msg['from'];
        }
        chat_messages[id] = msg['chat_history'];
        render_chat(id);
      }
      if (msg['fight']){
        fight = msg['fight'];
        render_fight();
      }
      if (msg['fighters']){
        fighters = msg['fighters'];
        if(player){
          if(fight.fas==2){
            render_player_fight();
          }
        }
        else{ // MASTER
          render_master_fight();
        }
        // else if(player && fight.fase==1){
        //   render_dice_roll();
        // }
        // }else if(fight.render==2){
        //   render_player_fight();
        // }
      }
      if (msg['flash']){
        var el = document.getElementById('dnd-flash')
        if(el){
          clearTimeout(flash_timeout);
          el.innerHTML = msg['flash'];
          el.classList.remove('no-messages');
          flash_timeout = setTimeout(function(){
            //fade back
            el.classList.add('no-messages');
          }, flash_timeout_ms);
        }
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
