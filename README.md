# SupportHER
This app focuses on educating men about menstrual cycle enabling them to support their partner, friend, sister or daughter both emotionally and physically.

## Symptom assessment ("When to See a Doctor")

The Info tab includes an 8-question Yes/No check that tells the user how soon to involve a doctor. It is not a diagnostic tool. Questions and tiers follow patient guidance from the NHS and ACOG; sources are listed below.

### Questions

| # | Question | Tier |
|---|---|---|
| Q1 | Soaking through a pad or tampon in under 2 hours | Routine |
| Q2 | Severe pain that does not improve with over-the-counter medication | Urgent |
| Q3 | Fainted or felt extremely dizzy during her period | Urgent |
| Q4 | Fever alongside period symptoms | Urgent |
| Q5 | Period lasted more than 7 days | Routine |
| Q6 | Periods less than 21 days apart, or more than 35 days apart | Routine |
| Q7 | Bleeding after sexual intercourse | Routine |
| Q8 | Period pattern suddenly changed significantly | Routine |

### Result rule

Checked top to bottom; the first match wins.

| Condition | Result shown |
|---|---|
| Q1 and Q3 both Yes | Seek Emergency Care Now |
| Any urgent question Yes | Contact a Doctor Today |
| Any routine question Yes | Book a Doctor Visit |
| All No | No Warning Signs Flagged |

A single Yes never produces a reassuring result, and the app never describes symptoms as "normal". Results other than "No Warning Signs Flagged" list the symptoms that were reported.

### Test cases

| Answers | Expected result |
|---|---|
| Q1 + Q3 Yes | Seek Emergency Care Now |
| All eight Yes | Seek Emergency Care Now |
| Q2 only | Contact a Doctor Today |
| Q3 only | Contact a Doctor Today |
| Q4 only | Contact a Doctor Today |
| Q1 only | Book a Doctor Visit |
| Q5 only | Book a Doctor Visit |
| Q6 only | Book a Doctor Visit |
| Q7 only | Book a Doctor Visit |
| Q8 only | Book a Doctor Visit |
| All No | No Warning Signs Flagged |
| Q1 Yes, tap "Previous question", change Q1 to No, rest No | No Warning Signs Flagged |
| On Q1 | "Previous question" is not shown |

### Sources

- [NHS: Heavy periods](https://www.nhs.uk/conditions/heavy-periods/)
- [NHS: Period pain](https://www.nhs.uk/conditions/period-pain/)
- [NHS: Irregular periods](https://www.nhs.uk/conditions/irregular-periods/)
- [NHS: Bleeding between periods or after sex](https://www.nhs.uk/conditions/vaginal-bleeding-between-periods-or-after-sex/)
- [NHS: Toxic shock syndrome](https://www.nhs.uk/conditions/toxic-shock-syndrome/)
- [ACOG: Heavy menstrual bleeding](https://www.acog.org/womens-health/faqs/heavy-menstrual-bleeding)
- [ACOG: Abnormal uterine bleeding](https://www.acog.org/womens-health/faqs/abnormal-uterine-bleeding)
- [ACOG: Dysmenorrhea, painful periods](https://www.acog.org/womens-health/faqs/dysmenorrhea-painful-periods)
