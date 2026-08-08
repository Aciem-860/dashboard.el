# dashboard.el

Un petit dashboard pour Emacs, sans dépendance particulière.

Il affiche au démarrage :

- la date et l'heure
- quelques informations sur la machine
- les fichiers récemment ouverts (`recentf`)
- les projets connus de Projectile
- les marque-pages Emacs
- quelques raccourcis utiles

Les fichiers, projets et marque-pages sont directement cliquables.

## Installation

Copier `dashboard.el` dans un répertoire présent dans `load-path`, puis :

```elisp
(require 'dashboard)
```

Pour ouvrir le dashboard :

```elisp
(open-dashboard)
```

On peut par exemple l'utiliser comme écran de démarrage (si vous utilisez `use-package`):

```elisp
(use-package dashboard
  :load-path "~/.emacs.d/local-packages/dashboard"
  :commands open-dashboard
  :init
  (setq inhibit-startup-screen t)
  (setq initial-buffer-choice #'open-dashboard)
  :bind
  (("C-c d" . (lambda ()
                (interactive)
                (when (not (get-buffer "*dashboard*"))
                  (open-dashboard))
                (switch-to-buffer (open-dashboard))))))
```

## Raccourcis

| Touche | Action |
|--------|--------|
| `n` / `↓` | Ligne suivante |
| `p` / `↑` | Ligne précédente |
| `N` | Section suivante |
| `P` | Section précédente |
| `g` | Rafraîchir |
| `q` | Fermer le dashboard |
| `x` | Replier/déplier une section |

## Dépendances

Le dashboard utilise les variables suivantes lorsqu'elles sont disponibles :

- `recentf-list`
- `projectile-known-projects`
- `bookmark-alist`

Projectile n'est donc pas nécessaire pour faire fonctionner le dashboard ; ses projets sont simplement affichés si Projectile est installé et utilisé.

## Licence

GNU GPLv3
