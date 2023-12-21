﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(_)
    установитьВидимостьЭлементовФормы();
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(отказ, __)
    заполнитьПолеНаименованияДоговора();
    Если этоБессрочныйДоговор() И ЗначениеЗаполнено(Объект.ДатаОкончанияДоговора) Тогда
        очиститьПоляСрочногоДоговора();
    Иначе
        сообщение = проверкаЗаполненияДатыОкончанияДоговора();
        Если сообщение <> NULL Тогда
            сообщение.Сообщить();
            отказ = Истина;
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПризнакБессрочногоДоговораПриИзменении(_)
    установитьВидимостьЭлементовФормы();
КонецПроцедуры

&НаКлиенте
Процедура ДатаЗаключенияДоговораПриИзменении(_)
    заполнитьПолеНаименованияДоговора();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

// Устанавливает/отключает видимость для полей формы заполняемых в зависимости
// от признака бессрочности договора
&НаКлиенте
Процедура установитьВидимостьЭлементовФормы()
    этоСрочныйДоговор = НЕ этоБессрочныйДоговор();
    Элементы.ДатаОкончанияДоговора.Видимость = этоСрочныйДоговор;
    Элементы.ДатаОкончанияДоговора.АвтоОтметкаНезаполненного = этоСрочныйДоговор;
КонецПроцедуры

// Заполняет поле формы - НаименованиеДоговора по указанным в форме данным номера и даты договора
&НаКлиенте
Процедура заполнитьПолеНаименованияДоговора()
    Объект.Наименование = сформироватьСтрокуНаименованияДоговора(Объект.ВнешнийНомер,
            Объект.ДатаЗаключения);
КонецПроцедуры

// Параметры:
//  коллекцияПолейФормы - КоллекцияПолейФормы - коллекция объектов полей формы
&НаКлиенте
Процедура очиститьПоля(коллекцияПолейФормы)
    Для Каждого поле Из коллекцияПолейФормы Цикл
        Если (ТипЗнч(поле) = Тип("ТаблицаФормы")) И (ТипЗнч(Объект[поле.Имя]) =
                Тип("ДанныеФормыКоллекция")) Тогда
            Объект[поле.Имя].Очистить();
        Иначе
            Объект[поле.Имя] = NULL;
        КонецЕсли;
    КонецЦикла;
КонецПроцедуры

// Выполняет очистку значений полей формы используемых только для СрочногоДоговора
&НаКлиенте
Процедура очиститьПоляСрочногоДоговора()
    очиститьПоля(получитьПоляФормыТолькоДляСрочногоДоговора());
КонецПроцедуры

// Формирует строку наименования договора / вида: №договора от датаДоговора.
//
// Параметры:
//  номерДоговора - Строка - Номер договора
//  датаЗаключения - Дата - Дата заключения договора
//
// Возвращаемое значение:
//  Строка - наименования договора (прим. №123 от 12.05.2022 г)
&НаКлиенте
Функция сформироватьСтрокуНаименованияДоговора(Знач номерДоговора, Знач датаЗаключения)
    номерДоговораЗаполнен = ЗначениеЗаполнено(номерДоговора);
    датаДоговораЗаполнен = ЗначениеЗаполнено(датаЗаключения);

    Если НЕ номерДоговораЗаполнен Тогда
        Возврат "";
    КонецЕсли;

    номерДоговора = РаботаСоСтрокамиВызовСервера.ЗаменитьПоРегулярномуВыражению(
            номерДоговора, "^\s+|\s+$", "");
    номерДоговора = РаботаСоСтрокамиВызовСервера.ЗаменитьПоРегулярномуВыражению(
            номерДоговора, "^\D+(?=[0-9]+)", "");

    Возврат ?(НЕ датаДоговораЗаполнен, номерДоговора,
        СтрШаблон("№%1 от %2 г.", номерДоговора, Формат(датаЗаключения, "Л=ru_RU; ДФ=дд.MM.гггг")));
КонецФункции

&НаКлиенте
Функция этоБессрочныйДоговор()
    Возврат Объект.ПризнакБессрочногоДоговора;
КонецФункции

// Получить массив элементов полей формы доступных только для СрочногоДоговора
//
// Возвращаемое значение:
//  Массив - Массив элементов полей формы
&НаКлиенте
Функция получитьПоляФормыТолькоДляСрочногоДоговора()
    поляФормы = Новый Массив();
    поляФормы.Добавить(Элементы.ДатаОкончанияДоговора);

    Возврат поляФормы;
КонецФункции

// Выполняет проверку заполнения поля ДатаОкончанияДоговора. \
// Если поле ДатаОкончанияДоговора не прошло проверку - генерирует сообщение пользователю
//
// Параметры:
//   принудительно - Булево - Если Ложь проверка выполняется только для объекта с признаком БессрочностиДоговора
//
// Возвращаемое значение:
//   СообщениеПользователю - Если NULL - проверка прошла успешно, иначе возвращает сообщение с текстом ошибки проверки
&НаКлиенте
Функция проверкаЗаполненияДатыОкончанияДоговора(Знач принудительно = Ложь)
    этоСрочныйДоговор = НЕ этоБессрочныйДоговор();

    Если (принудительно ИЛИ этоСрочныйДоговор) И (НЕ ЗначениеЗаполнено(Объект.ДатаОкончанияДоговора)) Тогда
        сообщение = Новый СообщениеПользователю();
        сообщение.Текст = "Поле ""дата окончания договора"" не заполнено";
        сообщение.Поле = Элементы.ДатаОкончанияДоговора.Имя;
        Сообщение.КлючДанных = Объект.Ссылка;
        Сообщение.ПутьКДанным = "Объект";

        Возврат сообщение;
    КонецЕсли;

    Возврат NULL;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
