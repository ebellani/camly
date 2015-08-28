open Core.Std
open Async.Std

(** great guide on async
    http://janestreet.github.io/guide-async.html *)

let confirmation = "✓"

let from_endpoint w r =
  let stdout = (Writer.pipe (Lazy.force Writer.stdout)) in
  Pipe.iter r
            ~f:(fun value ->
                if value = confirmation
                then Pipe.write stdout "Message was received successfully.\n"
                else Pipe.write stdout value
                     >>= (fun () -> Pipe.write w confirmation))
            ~continue_on_error:true

let to_endpoint w =
  let stdin = (Reader.pipe (Lazy.force Reader.stdin)) in
  Pipe.iter stdin
            ~f:(fun value -> Pipe.write w value)
            ~continue_on_error:true

let make_chat_channel w r =
  let w', r' = (Writer.pipe w, Reader.pipe r) in
  ignore (from_endpoint w' r');
  ignore (to_endpoint w');
  Deferred.never ()

let connect ~port =
  ignore (Tcp.with_connection (Tcp.to_host_and_port "localhost" port)
                              (fun _addr r w -> make_chat_channel w r));
  Deferred.never ()

let serve ~port =
  let host_and_port =
    Tcp.Server.create
      ~on_handler_error:`Raise
      (Tcp.on_port port)
      (fun _addr r w -> make_chat_channel w r)
  in
  ignore (host_and_port : (Socket.Address.Inet.t, int) Tcp.Server.t Deferred.t);
  Deferred.never ()

let () =
  Command.async_basic
    ~summary:"Start an echo server"
    Command.Spec.(
    empty
    +> flag "-port" (optional_with_default 8765 int)
            ~doc:" Port to listen on (default 8765)"
    +> flag "-server" (optional_with_default true bool)
            ~doc:" Starts as a server or as a client. Defaults to false (client mode.)"
  ) (fun port server () -> if server then serve ~port else connect ~port)
  |> Command.run
