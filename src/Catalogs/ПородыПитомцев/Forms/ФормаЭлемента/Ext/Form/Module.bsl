﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(_)
    Объект.ВидПитомца = ?(Объект.ВидПитомца.Пустая(),
            ПредопределенноеЗначение("Перечисление.ВидыПитомцев.Кошка"), Объект.ВидПитомца);
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы
