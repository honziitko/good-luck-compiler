#pragma once

#include "utils.h"
namespace glc {
    using State = size_t;
    using Symbol = size_t;
    using Head = long long;
    enum class Direction { left, right };
    static constexpr State halt = 0;

    using empty_tape = utils::vector<Symbol>;

    template <State state_, Symbol symbol, Direction dir>
    struct transition_entry {
        static constexpr Symbol to_write = symbol;
        static constexpr State state = state_;
        static constexpr Direction direction = dir;
    };

    template <template <State, Symbol> class TransitionTable, class Machine>
    struct next_state_impl {};
    template <template <State, Symbol> class TransitionTable, class Machine>
    using next_state = typename next_state_impl<TransitionTable, Machine>::type;

    template <Head head, State state, class TapeLeft, class TapeRight>
    struct machine_state {};

    constexpr size_t headToIndex(Head head) {
        return (head >= 0) ? head : -head - 1;
    }

    constexpr Head directionToOffset(Direction dir) {
        return (dir == Direction::left) ? -1 : 1;
    }

    template <template <State, Symbol> class Trans, Head head, class TapeLeft, class TapeRight>
    struct next_state_impl<Trans, machine_state<head, halt, TapeLeft, TapeRight> > {
        using type = machine_state<head, halt, TapeLeft, TapeRight>;
    };
    template <template <State, Symbol> class Trans, State state, Head head, class TapeLeft, class TapeRight>
    struct next_state_impl<Trans, machine_state<head, state, TapeLeft, TapeRight> > {
        static constexpr bool is_right = head >= 0;
        using Tape = utils::ternary<is_right, TapeRight, TapeLeft>;
        using OtherTape = utils::ternary<is_right, TapeLeft, TapeRight>;
        static constexpr size_t tape_index = headToIndex(head);
        static constexpr bool allocate = tape_index >= Tape::len;
        using AllocatedTape = utils::ternary<allocate, typename Tape::template push_back<0>, Tape>;
        static constexpr Symbol read_symbol = AllocatedTape::template at<tape_index>();
        using Target = Trans<state, read_symbol>;

        static constexpr Symbol to_write = Target::to_write;
        static constexpr State new_state = Target::state;
        static constexpr Direction direction = Target::direction;

        static constexpr Head new_head = head + directionToOffset(direction);
        using NewTape = typename AllocatedTape::template set<to_write, tape_index>;
        using ResultLeft = machine_state<new_head, new_state, NewTape, OtherTape>;
        using ResultRight = machine_state<new_head, new_state, OtherTape, NewTape>;
        using type = utils::ternary<is_right, ResultRight, ResultLeft>;
    };

    template <template <State, Symbol> class TransitionTable, class Machine>
    struct loop_impl {};

    template <template <State, Symbol> class Trans, Head head, class TapeLeft, class TapeRight>
    struct loop_impl<Trans, machine_state<head, halt, TapeLeft, TapeRight> > {
        using type = machine_state<head, halt, TapeLeft, TapeRight>;
    };

    template <template <State, Symbol> class Trans, Head head, State state, class TapeLeft, class TapeRight>
    struct loop_impl<Trans, machine_state<head, state, TapeLeft, TapeRight> > {
        using type = typename loop_impl<Trans, next_state<Trans, machine_state<head, state, TapeLeft, TapeRight> > >::type;
    };

    template <template <State, Symbol> class Trans, class Machine>
    using loop = typename loop_impl<Trans, Machine>::type;
};
