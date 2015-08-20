open Core.Std
open Async.Std

let from_endpoint_transfer r =
  Pipe.transfer_id (Reader.pipe r)
                   (Writer.pipe (Lazy.force Writer.stdout))

let to_endpoint_transfer w =
  Pipe.transfer_id (Reader.pipe (Lazy.force Reader.stdin))
                   (Writer.pipe w)

let full_transfer w r =
  from_endpoint_transfer r;
  to_endpoint_transfer w

let connect ~port =
  (Tcp.with_connection (Tcp.to_host_and_port "localhost" port)
                       (fun _addr r w -> full_transfer w r));
  Deferred.never ()

let serve ~port =
  let host_and_port =
    Tcp.Server.create
      ~on_handler_error:`Raise
      (Tcp.on_port port)
      (fun _addr r w -> full_transfer w r)
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
