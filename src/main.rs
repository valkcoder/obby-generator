use eframe::egui;
use rand::prelude::IteratorRandom;
use rand::seq::SliceRandom;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ObbyPiece {
    id: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
struct TrainingData {
    good_starts: Vec<String>,
    good_ends: Vec<String>,
    good_combinations: Vec<(String, String)>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct ObbySequence {
    pieces: Vec<ObbyPiece>,
}

struct ObbyGeneratorApp {
    raw_training_json: String,
    training_data: TrainingData,
    generated_output: String,
    obby_length: usize,
    status_message: String,
    obby_sequence: Vec<ObbyPiece>,
}

impl Default for ObbyGeneratorApp {
    fn default() -> Self {
        Self {
            raw_training_json: String::new(),
            training_data: TrainingData::default(),
            generated_output: String::new(),
            obby_length: 5,
            status_message: String::new(),
            obby_sequence: Vec::new(),
        }
    }
}

impl eframe::App for ObbyGeneratorApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::CentralPanel::default().show(ctx, |ui| {
            egui::ScrollArea::both().show(ui, |ui| {
                ui.horizontal(|ui| {
                    // LEFT PANEL
                    ui.vertical(|ui| {
                        ui.heading("Valk's Obby Generator");

                        ui.label("Paste training data here (from Roblox plugin, JSON format):");
                        ui.add(
                            egui::TextEdit::multiline(&mut self.raw_training_json)
                                .desired_rows(10)
                                .desired_width(400.0)
                                .code_editor()
                                .frame(true)
                                .clip_text(true),
                        );

                        if ui.button("Load Training JSON").clicked() {
                            match serde_json::from_str::<TrainingData>(&self.raw_training_json) {
                                Ok(data) => {
                                    self.training_data = data;
                                    self.status_message = "✅ Training data loaded!".to_string();
                                }
                                Err(err) => {
                                    self.status_message = format!(
                                        "❌ Failed to parse training data ({} bytes): {}\nContent:\n{}",
                                        self.raw_training_json.len(),
                                        err,
                                        self.raw_training_json
                                    );
                                }
                            }
                        }

                        ui.separator();
                        ui.horizontal(|ui| {
                            ui.label("Obby Length (includes start & end):");
                            ui.add(
                                egui::DragValue::new(&mut self.obby_length).clamp_range(3..=100),
                            );
                        });

                        if ui.button("Generate Obby").clicked() {
                            let (json, sequence) = generate_sequence(
                                &self.training_data,
                                self.obby_length,
                                &mut self.status_message,
                            );
                            self.generated_output = json;
                            self.obby_sequence = sequence;
                        }

                        ui.separator();
                        ui.label("Generated Obby JSON:");
                        ui.add(
                            egui::TextEdit::multiline(&mut self.generated_output)
                                .desired_rows(10)
                                .desired_width(400.0)
                                .code_editor()
                                .frame(true)
                                .clip_text(true),
                        );

                        if ui.button("Copy Generated Obby JSON").clicked() {
                            ui.output_mut(|o| o.copied_text = self.generated_output.clone());
                            self.status_message = "✅ Copied obby JSON to clipboard.".to_string();
                        }                        

                        ui.separator();
                        if !self.status_message.is_empty() {
                            ui.label(&self.status_message);
                        }
                    });

                    // RIGHT PANEL
                    ui.vertical(|ui| {
                        ui.set_width(600.0);
                    
                        // Make the heading stay outside the scroll area
                        ui.heading("Edit Obby Sequence");
                    
                        egui::ScrollArea::vertical()
                            .max_height(400.0)
                            .show(ui, |ui| {
                                egui::Grid::new("obby_table")
                                    .striped(true)
                                    .min_col_width(150.0)
                                    .show(ui, |ui| {
                                        ui.label("Index");
                                        ui.label("Piece ID");
                                        ui.end_row();
                    
                                        let mut changed = false;
                    
                                        for (i, piece) in self.obby_sequence.iter_mut().enumerate() {
                                            ui.label(i.to_string());
                                            changed |= ui.text_edit_singleline(&mut piece.id).changed();
                                            ui.end_row();
                                        }
                    
                                        if changed {
                                            let new_json = serde_json::to_string_pretty(&ObbySequence {
                                                pieces: self.obby_sequence.clone(),
                                            })
                                            .unwrap_or("{}".to_string());
                    
                                            self.generated_output = new_json;
                                            self.status_message = "✅ Obby sequence updated.".to_string();
                                        }
                                    });
                            });
                    });                    
                });
            });
        });
    }
}

fn generate_sequence(
    data: &TrainingData,
    length: usize,
    status_out: &mut String,
) -> (String, Vec<ObbyPiece>) {
    let mut rng = rand::thread_rng();

    let start = match data.good_starts.choose(&mut rng) {
        Some(s) => s.clone(),
        None => return ("{\"error\": \"No good_starts found.\"}".into(), vec![]),
    };

    let end = match data.good_ends.choose(&mut rng) {
        Some(e) => e.clone(),
        None => return ("{\"error\": \"No good_ends found.\"}".into(), vec![]),
    };

    let mut sequence = vec![ObbyPiece { id: start.clone() }];
    let mut current = start.clone();
    let middle_count = length.saturating_sub(2);

    for _ in 0..middle_count {
        let next_combo = data
            .good_combinations
            .iter()
            .filter(|(a, _)| a == &current)
            .choose(&mut rng);

        if let Some((_, next)) = next_combo {
            sequence.push(ObbyPiece { id: next.clone() });
            current = next.clone();
        } else {
            break;
        }
    }

    sequence.push(ObbyPiece { id: end });

    *status_out = format!("✅ Obby generated with {} pieces.", sequence.len());
    if sequence.len() < length {
        *status_out = format!(
            "⚠️ Only generated {} out of {} pieces due to limited training data.",
            sequence.len(),
            length
        );
    }

    let json = serde_json::to_string_pretty(&ObbySequence {
        pieces: sequence.clone(),
    })
    .unwrap_or("{}".to_string());

    (json, sequence)
}

fn main() -> Result<(), eframe::Error> {
    let options = eframe::NativeOptions::default();
    eframe::run_native(
        "Valk's Obby Generator",
        options,
        Box::new(|_cc| Box::new(ObbyGeneratorApp::default())),
    )
}
