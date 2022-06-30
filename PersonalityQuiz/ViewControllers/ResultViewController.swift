//
//  ResultViewController.swift
//  PersonalityQuiz
//
//  Created by Alexey Efimov on 30.08.2021.
//

import UIKit


/*
Алгоритм решения:
 - производится расчет суммы взвешенных ответов по каждому типу животного;
 - веса, на которые взвешиваются ответы:
     - по первому вопросу вес всегда 1,0, т.к. нет возможности множественного выбора;
     - по второму вопросу вес зависит от количества выбранных вариантов:
        если выбран один ответ, вес 1,0; если два - вес каждого 0,5; три - 0,33; четыре - 0,25;
    - по третьему вопросу вес зависит от удаленности слайдера от центра выбранного ответа:
        - по 0,5 с двух сторон от значения, до которого производится округление
            (например, если центр двойка, то диапазон будет от 1,5 до 2,5);
        - чем больше удален слайдер в ту или другую сторону, тем меньше вес.

Расчет немного замороченный, но таким образом нивелируется ситуация с равным количеством ответов по нескольким животным. И пользователь всегда получит максимально точный ответ)
*/

class ResultViewController: UIViewController {
    
    
    @IBOutlet var youAreAnimalTitle: UILabel!
    @IBOutlet var youAreAnimalDefinition: UILabel!
    
    
    var answersChosen: [Answer]!
    var animalWeights: [Animal: Float] = [:]
    var youAreAnimal: Animal!
    
    var sliderValue: Float!
    var multipleAnswerWeight: Float {
        abs(0.5 - abs(sliderValue - Float(Int(sliderValue)))) * 2
    }
    
    var multipleChosenCount: Float {
        Float(answersChosen.count - 2)
    }
    
    
    private func result(for answers: [Answer]) {
        
        for answer in answers {
            
            if answer == answers.first  {
                animalWeights[answer.animal] = 1
            } else if answer == answers.last {
                if let weight = animalWeights[answer.animal] {
                    animalWeights.updateValue(weight + multipleAnswerWeight, forKey: answer.animal)
                } else {
                    animalWeights[answer.animal] = multipleAnswerWeight
                }
            } else {
                if let weight = animalWeights[answer.animal] {
                    animalWeights.updateValue(weight + 1 / multipleChosenCount, forKey: answer.animal)
                } else {
                    animalWeights[answer.animal] = 1 / multipleChosenCount
                }
            }
        }
        
        let animalWeightsSorted = animalWeights.sorted { $0.value > $1.value }
        youAreAnimal = animalWeightsSorted.first?.key
        
    }
            

    override func viewDidLoad() {
        super.viewDidLoad()
        result(for: answersChosen)
        youAreAnimalTitle.text = "Вы - \(String(youAreAnimal.rawValue))"
        youAreAnimalDefinition.text = String(youAreAnimal.definition)
        navigationItem.hidesBackButton = true

    
    }
}

extension Answer: Equatable {
    static func == (lhs: Answer, rhs: Answer) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.animal == rhs.animal
    }
}

