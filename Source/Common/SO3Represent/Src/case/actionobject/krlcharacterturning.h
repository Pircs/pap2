#ifndef KRLCHARACTERTURNING_H
#define KRLCHARACTERTURNING_H

enum RL_TURNING
{
    RL_TURNING_STAND_NONE,
    RL_TURNING_STAND_FACE_TURN_LEFT,
    RL_TURNING_STAND_FACE_TURN_RIGHT,
    RL_TURNING_STAND_FOOT_TURN_LEFT,
    RL_TURNING_STAND_FOOT_TURN_RIGHT,

    RL_TURNING_MOVING_NONE,
    RL_TURNING_MOVING_FACE_TURN_LEFT,
    RL_TURNING_MOVING_FACE_TURN_RIGHT,
};

RL_TURNING GetTurning(RL_TURNING nTurning, BOOL bMoving, float fFaceYaw, float fFootYaw, float fPreviousFaceYaw, float fPreviousFootYaw);

#endif // KRLCHARACTERTURNING_H
