
# NoShowGuard — Healthcare Appointment No-Show Prediction

**GitHub Repository:** https://github.com/Drishanv/NoShowGuard

## Project Summary

- **Part 1 — Data Cleaning:** Processed 1,020 raw appointment records and retained 990 clean records, identifying 218 no-shows (22.0%).
- **Part 2 — SQL Analysis:** Appointments booked 31+ days in advance had the highest no-show rate of 60.5%.
- **Part 3 — Machine Learning:** Logistic Regression achieved a test ROC-AUC of 0.7891 and was selected as the final prediction model.
- **Part 4 — Generative AI:** Analysed 10 follow-up notes; both notes classified as forgotten/no-reminder cases had `reminder_sent = No`.

## Business Recommendation

NoShowGuard can help clinics identify appointments that may require additional follow-up before the scheduled visit. In the cleaned dataset, 218 out of 990 appointments (22.0%) were no-shows. Appointments booked 31+ days in advance had a 60.5% no-show rate, indicating that longer booking lead times deserve attention. The selected Logistic Regression model achieved a test ROC-AUC of 0.7891. At a probability threshold of 0.35, it flagged 49 appointments in the test set, achieving 57.1% precision and 57.1% recall. Clinics can use these predictions to prioritise reminder calls and appointment confirmations, subject to their available call capacity. The Generative AI analysis also found that both of the two notes classified as `forgot_or_no_reminder` had no recorded reminder sent. Clinics should investigate reminder delivery and booking lead times as potential areas for improvement. These findings are based on observational data and should be validated before operational implementation.

## Selected Machine Learning Model

**Selected Model: Logistic Regression**

Logistic Regression was selected because it achieved the strongest training cross-validation ROC-AUC (0.7737) among the evaluated models. Its final test ROC-AUC was 0.7891.

A probability threshold of **0.35** was selected using out-of-fold training predictions to improve no-show detection compared with the default threshold of 0.50.

### Test Set Performance

| Metric | Result |
|---|---:|
| Precision | 0.5714 |
| Recall | 0.5714 |
| F1-score | 0.5714 |
| ROC-AUC | 0.7891 |
| Appointments Flagged | 49 |
| Selected Threshold | 0.35 |

## Limitations

1. **Limited GenAI sample:** The 10 follow-up notes are illustrative and cannot establish the actual reasons for no-shows across all clinics.
2. **Threshold and call capacity:** The selected 0.35 threshold may need adjustment depending on the number of follow-up calls clinics can handle.
3. **Observational data:** The analysis identifies associations, not causes. For example, an association between reminders and no-shows does not prove that reminders directly prevent missed appointments.

## Project Structure

```text
NoShowGuard/
│
├── 01_ingest_clean.ipynb
├── 02_queries.sql
├── 03_model.ipynb
├── 04_genai.ipynb
├── README.md
│
├── appointments_clean.csv
├── clinics_enriched.csv
├── load_data.sql
├── notes_analysed.csv
├── rejected_rows.json
├── test_risk_scores.csv
│
└── data/
    ├── appointments.csv
    ├── clinics.csv
    └── followup_notes.csv
```

## Technologies Used

- Python
- Pandas and NumPy
- SQL and MySQL
- Scikit-learn
- Logistic Regression, Decision Tree and Random Forest
- Google Gemini API
- Pydantic
- Google Colab

## Project Objective

The objective of NoShowGuard is to analyse healthcare appointment data, identify patterns associated with missed appointments, predict no-show risk using machine learning, and analyse patient follow-up notes using Generative AI.

**Note:** The project is intended for analytical and educational purposes. Model predictions should support, not replace, clinic decision-making.
