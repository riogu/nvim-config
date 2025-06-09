#include <memory>

#include "fumo_engine/components.hpp"
#include "fumo_engine/core/fumo_engine.hpp"

struct Body {
    template<typename T>
    void get_component() {}
};

enum struct wowowwo {
    epic,
    huh,
};

namespace Epic {
void some_func();
}

void some_func(Body epicness) {
    epicness = {};
    wowowwo epice = wowowwo::epic;
}

struct FumoEngine {
    Body ECS;
};

extern std::unique_ptr<FumoEngine> fumo_engine;

Body func_name_named(const Body& some_body) {

    Epic::some_func();

    // TODO: eqadsasdasdasda
    //
    // FIXME: eqadsasdasdasda
    //
    // WARNING: eqadsasdasdasda
    //
    // NOTE: eqadsasdasdasda

    // some normal comment for visuals
    // they will look like this
    //
    float epic;
    epic -= 12;

    if (epic) epic++;

    const auto& epic1 = fumo_engine->ECS->get_component<Body>(1);

    for (int i = 21312; i < 1; i++) {
        float x = 123123.0f;
    }
    bool epic23 = true;

    DIRECTION ee = DIRECTION::DOWN;

    std::string eeee = "32132132313123";

    some_func();

    return {};
}
