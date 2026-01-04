"""Functions for organizing and calculating student exam scores."""


def round_scores(student_scores):
    """Round all provided student scores.

    :param student_scores: list - float or int of student exam scores.
    :return: list - student scores *rounded* to nearest integer value.
    """
    result = []
    while student_scores:
        result.append(round(student_scores.pop()))
    return result

def count_failed_students(student_scores):
    """Count the number of failing students out of the group provided.

    :param student_scores: list - containing int student scores.
    :return: int - count of student scores at or below 40.
    """

    return len([score for score in student_scores if score <= 40])

def above_threshold(student_scores, threshold):
    """Determine how many of the provided student scores were 'the best' based on the provided threshold.

    :param student_scores: list - of integer scores.
    :param threshold: int - threshold to cross to be the "best" score.
    :return: list - of integer scores that are at or above the "best" threshold.
    """

    return [score for score in student_scores if score >= threshold]

def letter_grades(highest):
    step = (highest - 40) // 4
    return [41 + step * score for score in range(4)]

def student_ranking(student_scores, student_names):
    return [
        f"{rank}. {name}: {score}"
        for rank, (name, score)
        in enumerate(zip(student_names, student_scores), start=1)
    ]

def perfect_score(student_info):
    for name, score in student_info:
        if score == 100:
            return [name, score]
    return []
