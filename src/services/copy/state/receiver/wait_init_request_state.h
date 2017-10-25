#ifndef SSF_SERVICES_COPY_STATE_RECEIVER_WAIT_INIT_REQUEST_STATE_H_
#define SSF_SERVICES_COPY_STATE_RECEIVER_WAIT_INIT_REQUEST_STATE_H_

#include <msgpack.hpp>

#include <ssf/log/log.h>

#include "common/error/error.h"
#include "common/filesystem/filesystem.h"

#include "services/copy/i_copy_state.h"
#include "services/copy/packet/init.h"
#include "services/copy/packet_helper.h"
#include "services/copy/state/on_abort.h"
#include "services/copy/state/receiver/abort_receiver_state.h"
#include "services/copy/state/receiver/send_init_reply_state.h"

namespace ssf {
namespace services {
namespace copy {

class WaitInitRequestState : ICopyState {
 public:
  template <typename... Args>
  static ICopyStateUPtr Create(Args&&... args) {
    return ICopyStateUPtr(
        new WaitInitRequestState(std::forward<Args>(args)...));
  }

 private:
  WaitInitRequestState() : ICopyState() {}

 public:
  // ICopyState
  void Enter(CopyContext* context, boost::system::error_code& ec) {
    SSF_LOG("microservice", trace, "[copy][wait_init_request] enter");
  }

  bool FillOutboundPacket(CopyContext* context, Packet* packet,
                          boost::system::error_code& ec) {
    return false;
  }

  void ProcessInboundPacket(CopyContext* context, const Packet& packet,
                            boost::system::error_code& ec) {
    if (packet.type() == PacketType::kAbort) {
      return OnReceiverAbortPacket(context, packet, ec);
    }

    if (packet.type() != PacketType::kInitRequest) {
      SSF_LOG("microservice", debug,
              "[copy][wait_init_request] cannot "
              "process inbound packet. "
              "not an InitRequest");
      context->SetState(
          AbortReceiverState::Create(ErrorCode::kInboundPacketNotSupported));
      return;
    }

    // create InitRequest struct from payload
    boost::system::error_code convert_ec;
    InitRequest init_req;
    PacketToPayload(packet, init_req, convert_ec);
    if (convert_ec) {
      SSF_LOG("microservice", debug,
              "[copy][wait_init_request] cannot "
              "convert packet to init request");
      context->SetState(
          AbortReceiverState::Create(ErrorCode::kInitRequestPacketCorrupted));
      return;
    }

    context->Init(init_req.input_filepath, init_req.check_file_integrity,
                  init_req.stdin_input, 0, init_req.resume, init_req.filesize,
                  init_req.output_dir, init_req.output_filename);

    ssf::Path output_path(init_req.output_dir);
    output_path /= init_req.output_filename;

    boost::system::error_code fs_ec;
    if (!context->fs.IsDirectory(init_req.output_dir, fs_ec)) {
      SSF_LOG("microservice", debug,
              "[copy][wait_init_request] output "
              "directory {} not found",
              init_req.output_dir);
      context->SetState(
          AbortReceiverState::Create(ErrorCode::kOutputDirectoryNotFound));
      return;
    }

    // try to create output directory
    context->fs.MakeDirectories(output_path.GetParent(), fs_ec);
    fs_ec.clear();
    if (!context->fs.IsDirectory(output_path.GetParent(), fs_ec)) {
      SSF_LOG("microservice", debug,
              "[copy][wait_init_request] output file "
              "directory not found");
      context->SetState(
          AbortReceiverState::Create(ErrorCode::kOutputFileDirectoryNotFound));
    }

    auto& output_fh = context->output;

    std::ios_base::openmode open_flags =
        std::ofstream::out | std::ofstream::binary;
    if (context->fs.IsFile(output_path, fs_ec)) {
      open_flags |= std::ofstream::in;
    }
    if (!context->resume) {
      // trunc file
      open_flags |= std::ofstream::trunc;
    } else {
      // seek to the end of stream
      open_flags |= std::ofstream::ate;
    }
    output_fh.open(output_path.GetString(), open_flags);
    if (!output_fh.is_open()) {
      SSF_LOG("microservice", debug,
              "[copy][wait_init_request] cannot open output file {}",
              output_path.GetString());
      context->SetState(
          AbortReceiverState::Create(ErrorCode::kOutputFileNotAvailable));
      return;
    }

    context->SetState(SendInitReplyState::Create());
  }

  bool IsTerminal(CopyContext* context) { return false; }
};

}  // copy
}  // services
}  // ssf

#endif  // SSF_SERVICES_COPY_STATE_WAIT_INIT_REQUEST_STATE_H_