import Foundation

struct Assignment: Identifiable, Codable, Equatable {
    let id: String
    let whereTags: [String]
    let effort: Int
    let text: String
    let sub: String
}

let BANK: [Assignment] = [
    Assignment(id: "h-l-1", whereTags: ["home"], effort: 1, text: "Film him right where he already is.", sub: "No repositioning. Ten seconds. Don't ask him to move."),
    Assignment(id: "h-l-2", whereTags: ["home"], effort: 1, text: "Get the door light landing on the floor near him.", sub: "Just the light and whatever's sitting in it."),
    Assignment(id: "h-l-3", whereTags: ["home"], effort: 1, text: "Zoom in on his paws for a few seconds.", sub: "Doesn't matter what he's doing with them."),
    Assignment(id: "h-l-4", whereTags: ["home"], effort: 1, text: "Record the sound of him breathing or sighing.", sub: "Eyes closed is fine — this one's about the sound."),
    Assignment(id: "h-l-5", whereTags: ["home"], effort: 1, text: "Film him in his usual spot, from the doorway.", sub: "Don't get closer. Just capture the room he's in."),
    Assignment(id: "h-o-1", whereTags: ["home"], effort: 2, text: "Get to his eye level and film him watching out the window.", sub: "Hold the shot longer than feels natural."),
    Assignment(id: "h-o-2", whereTags: ["home"], effort: 2, text: "Follow him for a few steps as he moves between rooms.", sub: "One continuous shot. No cuts."),
    Assignment(id: "h-o-3", whereTags: ["home"], effort: 2, text: "Film his face straight on while he's alert.", sub: "Say his name once, then just watch what happens."),
    Assignment(id: "h-o-4", whereTags: ["home"], effort: 2, text: "Golden light is hitting the window. Get low and film 10 seconds of him in it.", sub: "Don't edit it."),
    Assignment(id: "h-o-5", whereTags: ["home"], effort: 2, text: "Catch him reacting to a word he knows.", sub: "Walk, treat, outside — whatever gets his ears up."),
    Assignment(id: "h-g-1", whereTags: ["home"], effort: 3, text: "One fifteen-second shot. One angle. No cuts.", sub: "Pick the best light in the house right now."),
    Assignment(id: "h-g-2", whereTags: ["home"], effort: 3, text: "Film the thing he does that only he does.", sub: "The weird little habit. You know the one."),
    Assignment(id: "h-g-3", whereTags: ["home"], effort: 3, text: "Two angles of the same moment — wide, then close.", sub: "Don't restage it between takes."),
    Assignment(id: "o-l-1", whereTags: ["out"], effort: 1, text: "Film the first three seconds after you unclip the leash.", sub: "Just that first burst of movement."),
    Assignment(id: "o-l-2", whereTags: ["out"], effort: 1, text: "Catch him sniffing something like it's the most important thing in the world.", sub: "You already know the face."),
    Assignment(id: "o-o-1", whereTags: ["out"], effort: 2, text: "Get him ahead of you on the path, low angle.", sub: "Let him lead the shot."),
    Assignment(id: "o-o-2", whereTags: ["out"], effort: 2, text: "Low angle against the sky while he's mid-stride.", sub: "Aim up. Let the sky do the work."),
    Assignment(id: "o-o-3", whereTags: ["out"], effort: 2, text: "Film the moment he notices something in the distance.", sub: "The ears, the posture, the pause — that's the shot."),
]

func pacingNote(_ minutes: Int) -> String {
    if minutes >= 15 { return "You've got the time — let this one run longer than feels natural." }
    if minutes >= 5 { return "No need to rush this one." }
    return "Quick — don't overthink it."
}
