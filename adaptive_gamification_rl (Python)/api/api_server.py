from fastapi import FastAPI
from pydantic import BaseModel
from export.export_policy_json import load_policy_dict

policy = load_policy_dict('export/adaptive_policy.json')
app = FastAPI(title="Adaptive Gamification API")

class LearnerState(BaseModel):
    competence: float
    engagement: float
    motivation: float
    flow: float

def encode_state(state: LearnerState):
    return f"{round(state.competence,1)},{round(state.engagement,1)},{round(state.motivation,1)},{round(state.flow,1)}"

@app.post("/get_action")
def get_action(state: LearnerState):
    key = encode_state(state)
    action = policy.get(key, 0)
    return {"action": action}
