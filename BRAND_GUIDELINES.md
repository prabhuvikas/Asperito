# Asperito design tokens

The system follows Apple's HIG: photography is the primary content, system semantic colors are used for standard sheets and forms, and a dark camera chrome avoids distracting from the image.

| Token | HEX | Role |
|---|---|---|
| Midnight | #10151D | launch and viewfinder shell |
| Graphite | #1D2632 | camera trays and onboarding panels |
| Champagne gold | #E8BE78 | primary action (light) |
| Champagne gold dark | #F2C77F | brand accent for dark appearance |
| Ivory | #F7F3EA | camera controls / white-on-dark text |
| Mist | #B4BFCA | secondary camera labels |
| Focus cyan | #73D2D3 | optional instructional accent |

Use `Color.primary` / `Color.secondary` / system background colors for ordinary iOS controls. Avoid bright gold on every action. The camera shutter stays white.

## Launch and onboarding

`LaunchScreen.storyboard` is a static midnight background with the same small wordmark as the camera interface. It does not create an artificial loading delay. The selected director-hands framing artwork is shown in onboarding via `DirectorLogo.imageset`, and becomes the App Store icon. A launch screen is not an advertising splash.

## Official guidance
- https://developer.apple.com/design/human-interface-guidelines/color
- https://developer.apple.com/design/human-interface-guidelines/launching
- https://developer.apple.com/design/human-interface-guidelines/dark-mode
