# Web tracker for offline games

WIP

## Connection protocol

client: "secret_string: command[:options]"

- get_player  // get current player info
- get_master  // get current master info
- get_chat    // get current chat history
- message     // send new chat message
  - options={'id': 'uniq id','text': 'message text'}

server: json

```
{
  'chat':  // new message in chat
  {
    'id': 'uniq id',
    'from': 'from',
    'text': 'message text'
  },
  'chat_history': //chat history
  [
    {'id': 'uniq_id','from':'from','text':'msg text'},...
  ],
  'got_message': // message receive confirmation
  {
    {id: 'uniq_id'}
  },
  'player': //player info
  {
    'name': '...',
    ...
  },
  'master': //master info
  {
    'name': '...',
    ...
  },
  ...
}
```

### Messages