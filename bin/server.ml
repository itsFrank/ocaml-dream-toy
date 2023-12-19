open Ppx_yojson_conv_lib.Yojson_conv.Primitives
open Lwt.Syntax
module UMap = Map.Make (String)

let user_map = ref UMap.empty

type message_object = { assetid : string } [@@deriving yojson]

let () =
  Dream.run ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.router
       [ Dream.get "/asset/:userid" (fun req ->
           let userid = Dream.param req "userid" in
           match UMap.find_opt userid !user_map with
           | Some assetid -> Dream.json (Format.sprintf "{\"value\": %s}" assetid)
           | None ->
             Dream.json (Format.sprintf "{\"error\":\"no data for user %s\"}" userid))
       ; Dream.post "/asset/:userid" (fun req ->
           let* body = Dream.body req in
           let success =
             try
               let msg = body |> Yojson.Safe.from_string |> message_object_of_yojson in
               let userid = Dream.param req "userid"
               and assetid = msg.assetid in
               user_map := UMap.add userid assetid !user_map;
               true
             with
             | _ -> false
           in
           match success with
           | true -> Dream.json "{}"
           | false -> Dream.json "{\"error\":\"error parsing input\"}")
       ; Dream.post "/asset:clear" (fun _ ->
           user_map := UMap.empty;
           Dream.json "{}")
       ]
;;
