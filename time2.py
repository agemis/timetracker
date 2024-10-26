import tkinter as tk
from datetime import datetime, timedelta

class TimeTrackerApp:
    def __init__(self, master):
        self.master = master
        master.title("Suivi du Temps - 7 Catégories")

        # Initialisation des variables
        self.categories = ["Réunions", "Incidents", "Tickets",
                           "Changes/maj", "Doc/cmdb", "Améliorations", "Autres"]  # Vous pouvez renommer "Autres" selon vos besoins
        self.current_category = None
        self.start_time = None
        self.total_times = {category: timedelta(0) for category in self.categories}

        # Création de l'interface
        self.create_widgets()
        self.update_time_labels()

    def create_widgets(self):
        # Cadre pour les boutons
        self.button_frame = tk.Frame(self.master)
        self.button_frame.pack(pady=10)

        # Création des boutons pour les catégories
        self.buttons = {}
        for category in self.categories:
            button = tk.Button(self.button_frame, text=category, width=15,
                               command=lambda c=category: self.switch_category(c))
            button.pack(pady=2)
            self.buttons[category] = button

        # Bouton Pause
        self.pause_button = tk.Button(self.master, text="Pause", width=15,
                                      command=self.pause_timer)
        self.pause_button.pack(pady=5)

        # Labels pour afficher le temps passé
        self.time_frame = tk.Frame(self.master)
        self.time_frame.pack(pady=10)

        self.time_labels = {}
        for category in self.categories:
            label = tk.Label(self.time_frame, text=f"{category}: 00:00:00",
                             font=("Arial", 10))
            label.pack()
            self.time_labels[category] = label

        # Bouton pour le résumé
        self.summary_button = tk.Button(self.master, text="Afficher le Résumé",
                                        command=self.show_summary)
        self.summary_button.pack(pady=10)

    def switch_category(self, new_category):
        now = datetime.now()
        if self.current_category:
            # Arrêter le chronomètre de la catégorie précédente
            elapsed = now - self.start_time
            self.total_times[self.current_category] += elapsed
            print(f"Arrêt de {self.current_category} à {now.strftime('%H:%M:%S')}, temps écoulé: {elapsed}")
            # Réinitialiser la couleur du bouton précédent
            self.buttons[self.current_category].config(bg="SystemButtonFace")

        # Démarrer le chronomètre pour la nouvelle catégorie
        self.current_category = new_category
        self.start_time = now
        self.buttons[new_category].config(bg="green")
        print(f"Démarrage de {new_category} à {now.strftime('%H:%M:%S')}")

        # Réinitialiser le bouton Pause
        self.pause_button.config(bg="SystemButtonFace")

    def pause_timer(self):
        now = datetime.now()
        if self.current_category:
            # Arrêter le chronomètre de la catégorie en cours
            elapsed = now - self.start_time
            self.total_times[self.current_category] += elapsed
            print(f"Pause de {self.current_category} à {now.strftime('%H:%M:%S')}, temps écoulé: {elapsed}")
            # Réinitialiser la couleur du bouton de la catégorie
            self.buttons[self.current_category].config(bg="SystemButtonFace")

            # Indiquer que nous sommes en pause
            self.current_category = None
            self.start_time = None
            self.pause_button.config(bg="orange")
        else:
            print("Aucune catégorie en cours pour mettre en pause.")

    def update_time_labels(self):
        now = datetime.now()
        for category in self.categories:
            total_time = self.total_times[category]
            if category == self.current_category and self.start_time:
                total_time += now - self.start_time
            time_str = str(total_time).split(".")[0]
            self.time_labels[category].config(text=f"{category}: {time_str}")
        # Mise à jour toutes les secondes
        self.master.after(1000, self.update_time_labels)

    def show_summary(self):
        summary_window = tk.Toplevel(self.master)
        summary_window.title("Résumé du Temps")
        summary_text = "Temps total passé par catégorie :\n\n"
        for category, total_time in self.total_times.items():
            time_str = str(total_time).split(".")[0]
            summary_text += f"{category}: {time_str}\n"
        tk.Label(summary_window, text=summary_text, font=("Arial", 12)).pack(padx=10, pady=10)

        # Option pour enregistrer le résumé
        save_button = tk.Button(summary_window, text="Enregistrer le Résumé",
                                command=self.save_summary)
        save_button.pack(pady=5)

    def save_summary(self):
        with open("resume_temps1.txt", "w") as file:
            file.write("Temps total passé par catégorie :\n\n")
            for category, total_time in self.total_times.items():
                time_str = str(total_time).split(".")[0]
                file.write(f"{category}: {time_str}\n")
        print("Résumé enregistré dans 'resume_temps.txt'.")

    def on_close(self):
        # Enregistrer automatiquement le résumé à la fermeture
        self.save_summary()
        self.master.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = TimeTrackerApp(root)
    root.protocol("WM_DELETE_WINDOW", app.on_close)
    root.mainloop()
