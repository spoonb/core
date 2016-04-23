/*
 * Copyright 2016 C. Brett Witherspoon
 *
 * See LICENSE for more details.
 */

/**
 * Module: hazard
 */
module hazard
    import core::id_t;
    import core::ex_t;
    import core::mm_t;
    import core::wb_t;
    import core::isload;
    import core::isstore;
    import core::isjump;
    import core::isbranch;
(
    axis.monitor decode,
    axis.monitor execute,
    axis.monitor memory,
    axis.monitor writeback,
    output logic bubble,
    output logic stall
);
    id_t id;
    ex_t ex;
    mm_t mm;
    wb_t wb;

    opcodes::opcode_t opcode;

    enum logic { READ, IDLE } state = IDLE;

    assign id = decode.tdata;
    assign ex = execute.tdata;
    assign mm = memory.tdata;
    assign wb = writeback.tdata;

    assign opcode = id.data.ir.r.opcode;

    wire branch = opcode == opcodes::JAL || opcode == opcodes::JALR ||
                  opcode == opcodes::BRANCH;

    // Memory read hazard
    always_ff @(posedge decode.aclk)
        case (state)
            IDLE:
                if (opcode == opcodes::LOAD)
                    state <= READ;
            READ:
                if (core::isload(wb.ctrl.op))
                    state <= IDLE;
        endcase

    assign bubble = branch;

    assign stall = state == READ;

endmodule