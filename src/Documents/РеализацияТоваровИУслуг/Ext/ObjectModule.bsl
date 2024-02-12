﻿#Область ПрограммныйИнтерфейс

// Устарело. В текущей реализации не используется.
// Обновление суммы документа выполняется в процессе заполнения формы.\
// Обновляет поле СуммаДокумента.\
// Для корректной рабаты все суммы по строкам ТЧ должны быть предварительно рассчитаны.\
//
Процедура ОбновитьСуммуДокумента() Экспорт
    опцииРасчета = Документы.РеализацияТоваровИУслуг.ПолучитьПоляДляРасчетаСуммыДокумента();
    сумма = РаботаСДокументамиКлиентСервер.РассчитатьСуммуДокумента(ЭтотОбъект, опцииРасчета);
    СуммаДокумента = сумма;
КонецПроцедуры

// Параметры:
//  принудительно - Булево - Если Ложь - проверяет только если признак оплаты не установлен ранее.
//  По Умолчанию - Истина
Процедура ОбновитьСтатусОплатыДокумента(Знач принудительно = Истина) Экспорт
    Если принудительно ИЛИ ПризнакОплаты <> Перечисления.ПризнакиОплаты.ПолностьюОплачен Тогда
        ПризнакОплаты = Документы.РеализацияТоваровИУслуг.ПроверитьОплатуДокумента(Ссылка).ПризнакОплаты;
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ПрограммныйИнтерфейс

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(данныеЗаполнения, __, ___)
    Если ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.ЗаписьКлиента") Тогда
        ДатаОказанияУслуги = данныеЗаполнения.ДатаЗаписи;
        Клиент = данныеЗаполнения.Клиент;

        Если данныеЗаполнения.УслугаОказана Тогда // Ошибка! Попытка повторной реализации услуг по записи клиента
            сообщениеОшибки = СтрШаблон(
                    "Данная запись клиента ""%1"" от ""%2"" оказана и учтена в документах реализации услуг.
                    |Нельзя создавать документ реализации на основании закрытой или отмененной записи клиента.",
                    Клиент, ДатаОказанияУслуги);

            ВызватьИсключение сообщениеОшибки;

        Иначе
            Сотрудник = данныеЗаполнения.Сотрудник;
            ДокументОснование = данныеЗаполнения.Ссылка;
            Для Каждого текСтрокаУслуги Из данныеЗаполнения.Услуги Цикл
                новаяСтрока = Услуги.Добавить();
                новаяСтрока.Стоимость = текСтрокаУслуги.Стоимость;
                новаяСтрока.Услуга = текСтрокаУслуги.Услуга;
                СуммаДокумента = СуммаДокумента + текСтрокаУслуги.Стоимость;
            КонецЦикла;
        КонецЕсли;
    КонецЕсли;

    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(отказ, __)
    Если ЗначениеЗаполнено(ДокументОснование) И НЕ ДокументОснование.Проведен Тогда
        отказ = Истина;
        ВызватьИсключение "Документ основание должен быть проведен.";
    КонецЕсли;
    
    очиститьДвиженияДокумента();
    выполнитьВсеДвиженияДокумента(отказ);

    Если НЕ отказ Тогда
        записатьДвижения();
        обновитьСтатусОплатыДокументаОснования(Истина);
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область ЗапросыДанных
// Получает выборку Номенклатуры текущего документа и остатки на складе по товарам
//
// Параметры:
//  менеджерТаблиц - МенеджерВременныхТаблиц, Неопределено
//
// Возвращаемое значение:
//  - Выборка
//
Функция получитьВыборкуНоменклатураДокументаИОстатки(менеджерТаблиц = Неопределено)
    менеджерТаблиц = ?(менеджерТаблиц = Неопределено, Новый МенеджерВременныхТаблиц, менеджерТаблиц);

    запросНоменклатуры = Новый Запрос;
    запросНоменклатуры.МенеджерВременныхТаблиц = менеджерТаблиц;
    запросНоменклатуры.УстановитьПараметр("Ссылка", Ссылка);
    запросНоменклатуры.УстановитьПараметр("Склад", Склад);
    запросНоменклатуры.УстановитьПараметр("МоментВремени", Новый Граница(МоментВремени()));

    текстЗапросаТоваровИУслугДокумента =
        "ВЫБРАТЬ    // Товары
        |	РеализацияТоваровИУслугТовары.Товар КАК Номенклатура,
        |	&СКЛАД КАК Склад,
        |	СУММА(РеализацияТоваровИУслугТовары.Количество) КАК Количество,
        |	СУММА(РеализацияТоваровИУслугТовары.Сумма) КАК Сумма
        |
        |ПОМЕСТИТЬ ВТ_Товары
        |
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг.Товары КАК РеализацияТоваровИУслугТовары
        |
        |ГДЕ
        |	РеализацияТоваровИУслугТовары.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияТоваровИУслугТовары.Товар
        |
        |ОБЪЕДИНИТЬ ВСЕ
        |
        |ВЫБРАТЬ    // Услуги
        |	РеализацияТоваровИУслугУслуги.Услуга,
        |	NULL,
        |	NULL,
        |	СУММА(РеализацияТоваровИУслугУслуги.Стоимость)
        |
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг.Услуги КАК РеализацияТоваровИУслугУслуги
        |
        |ГДЕ
        |	РеализацияТоваровИУслугУслуги.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияТоваровИУслугУслуги.Услуга
        |
        |ИНДЕКСИРОВАТЬ ПО
        |	Номенклатура
        |;
        |";

    текстЗапросаОстатковПоТоварам =
        "ВЫБРАТЬ
        |	ВТ_Товары.Номенклатура КАК Номенклатура,
        |	ВЫБОР
        |		КОГДА ВТ_Товары.Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга)
        |			ТОГДА ЛОЖЬ
        |		ИНАЧЕ ИСТИНА
        |	КОНЕЦ КАК ЭтоТовар,
        |	ВТ_Товары.Номенклатура.Представление КАК НоменклатураПредставление,
        |	ВТ_Товары.Количество КАК КоличествоВДокументе,
        |	ВТ_Товары.Сумма КАК СуммаВДокументе,
        |	ВТ_Товары.Склад КАК Склад,
        |	ТоварыНаСкладахОстатки.СрокГодности КАК СрокГодности,
        |	ЕстьNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
        |	ЕстьNULL(ТоварыНаСкладахОстатки.СуммаОстаток, 0) КАК СуммаОстаток,
        |	ВТ_Товары.Номенклатура.СтатьяЗатрат КАК СтатьяЗатрат
        |
        |ИЗ
        |	ВТ_Товары КАК ВТ_Товары
        |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
        |			&МоментВремени,
        |			Склад = &Склад
        |               И Номенклатура В (
        |				ВЫБРАТЬ
        |					ВТ_Товары.Номенклатура
        |				ИЗ
        |					ВТ_Товары КАК ВТ_Товары)) КАК ТоварыНаСкладахОстатки
        |		ПО ВТ_Товары.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
        |
        |УПОРЯДОЧИТЬ ПО
        |	ТоварыНаСкладахОстатки.СрокГодности
        |
        |ИТОГИ
        |	МАКСИМУМ(КоличествоВДокументе),
        |	МАКСИМУМ(СуммаВДокументе),
        |	СУММА(КоличествоОстаток)
        |
        |ПО
        |	Номенклатура
        |";

    запросНоменклатуры.Текст = СтрШаблон("%1%2", текстЗапросаТоваровИУслугДокумента, текстЗапросаОстатковПоТоварам);

    Возврат запросНоменклатуры.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции
#КонецОбласти // ЗапросыДанных

#Область Движения
Процедура записатьДвижения()
    Движения.ТоварыНаСкладах.Записывать = Истина;
    Движения.Продажи.Записывать = Истина;
    Движения.УчетЗатрат.Записывать = Истина;
    Движения.ЗаказыКлиентов.Записывать = Истина;
КонецПроцедуры

Процедура очиститьДвиженияДокумента()
    записатьДвижения();
    Движения.Записать();
КонецПроцедуры

Процедура выполнитьВсеДвиженияДокумента(отказ = Ложь)
    запретПроведенияПриОтрицательныхОстатках = Константы.ЗапретПроведенияПриОтрицательныхОстатках.Получить();

    менеджерТаблиц = Новый МенеджерВременныхТаблиц;

    блокировка = получитьБлокировкуИзмененияТоварыНаСкладах();
    блокировка.Заблокировать();

    выборкаНоменклатураДокумента = получитьВыборкуНоменклатураДокументаИОстатки(менеджерТаблиц);
    Пока выборкаНоменклатураДокумента.Следующий() Цикл

        Если выборкаНоменклатураДокумента.ЭтоТовар Тогда
            количествоОстатков = выборкаНоменклатураДокумента.КоличествоОстаток - выборкаНоменклатураДокумента.КоличествоВДокументе;

            Если количествоОстатков < 0 Тогда
                сообщитьПользователюОПревышенииОстатков(
                    -количествоОстатков,
                    выборкаНоменклатураДокумента.НоменклатураПредставление);

                Если запретПроведенияПриОтрицательныхОстатках Тогда
                    отказ = Истина;
                КонецЕсли;
            КонецЕсли;

            Если отказ Тогда
                Продолжить;
            КонецЕсли;

            текущийОстатокВДокументе = выборкаНоменклатураДокумента.КоличествоВДокументе;
            выборкаНоменклатураДокументаПоСрокуГодности = выборкаНоменклатураДокумента.Выбрать();
            стоимостьОбщая = 0;

            количествоГруппТоваров = выборкаНоменклатураДокументаПоСрокуГодности.Количество();
            Пока выборкаНоменклатураДокументаПоСрокуГодности.Следующий() И текущийОстатокВДокументе > 0 Цикл
                результатСписания = выполнитьДвижениеТоварыНаСкладахРасход(
                        выборкаНоменклатураДокументаПоСрокуГодности,
                        текущийОстатокВДокументе);

                стоимостьОбщая = стоимостьОбщая + результатСписания.Сумма;
                текущийОстатокВДокументе = текущийОстатокВДокументе - результатСписания.Количество;

                // Код выполняется при отключенной опции ЗапретПроведенияПриОтрицательныхОстатках
                // и формирует отрицательный остаток по номенклатуре
                количествоГруппТоваров = количествоГруппТоваров - 1;
                Если количествоОстатков < 0 И количествоГруппТоваров = 0 И (НЕ запретПроведенияПриОтрицательныхОстатках) Тогда
                    выполнитьДвижениеТоварыНаСкладахРасход(
                        выборкаНоменклатураДокументаПоСрокуГодности,
                        текущийОстатокВДокументе, Истина);
                КонецЕсли;

            КонецЦикла;

            выполнитьДвижениеУчетЗатратОборот(выборкаНоменклатураДокумента, стоимостьОбщая);

        Иначе // Услуга
            Если (НЕ отказ) И ЗначениеЗаполнено(ДокументОснование) Тогда
                выполнитьДвижениеЗаказыКлиентовРасход(выборкаНоменклатураДокумента);
            КонецЕсли;

        КонецЕсли;

        Если НЕ отказ Тогда
            выполнитьДвижениеПродажиОборот(выборкаНоменклатураДокумента);
        КонецЕсли;

    КонецЦикла;
КонецПроцедуры

Процедура выполнитьДвижениеПродажиОборот(выборкаНоменклатураДокумента)
    движение = Движения.Продажи.Добавить();
    движение.Период = Дата;
    движение.Номенклатура = выборкаНоменклатураДокумента.Номенклатура;
    движение.Сотрудник = Сотрудник;
    движение.Клиент = Клиент;
    движение.Сумма = выборкаНоменклатураДокумента.СуммаВДокументе;
КонецПроцедуры

// Параметры:
//  выборкаТоварыПоПартиям - Выборка - выборка товаров на складе с группировкой по сроку годности
//  текущийОстатокВДокументе - Число - Остаток количества Номенклатуры (Товаров) в документе
//  этоОтрицательныйОстаток - Булево - Указывает закончились ли товары на складе
//
// Возвращаемое значение:
//  - Структура - { Сумма: Число - Стоимость выполненного списания по партии Товаров, Количество: Число - Количество выполненного списания }
//
Функция выполнитьДвижениеТоварыНаСкладахРасход(выборкаТоварыПоПартиям,
        Знач текущийОстатокВДокументе, Знач этоОтрицательныйОстаток = Ложь) // => Число

    доступноДляСписания = ?(этоОтрицательныйОстаток, текущийОстатокВДокументе,
            Мин(выборкаТоварыПоПартиям.КоличествоОстаток, текущийОстатокВДокументе));

    движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
    движение.Период = Дата;
    движение.Номенклатура = выборкаТоварыПоПартиям.Номенклатура;
    движение.Склад = выборкаТоварыПоПартиям.Склад;
    движение.СрокГодности = выборкаТоварыПоПартиям.СрокГодности;
    движение.Количество = доступноДляСписания;
    Если доступноДляСписания = выборкаТоварыПоПартиям.КоличествоОстаток ИЛИ этоОтрицательныйОстаток Тогда
        движение.Сумма = выборкаТоварыПоПартиям.СуммаОстаток;
    Иначе
        движение.Сумма = доступноДляСписания / выборкаТоварыПоПартиям.КоличествоОстаток
            * выборкаТоварыПоПартиям.СуммаОстаток;
    КонецЕсли;

    результатСписания = Новый Структура("Сумма, Количество", движение.Сумма, движение.Количество);

    Возврат результатСписания;
КонецФункции

Процедура выполнитьДвижениеУчетЗатратОборот(выборкаНоменклатураДокумента, Знач стоимостьОбщая)
    движение = Движения.УчетЗатрат.Добавить();
    движение.Период = Дата;
    движение.СтатьяЗатрат = выборкаНоменклатураДокумента.СтатьяЗатрат;
    движение.Сумма = стоимостьОбщая;
КонецПроцедуры

Процедура выполнитьДвижениеЗаказыКлиентовРасход(выборкаНоменклатураДокумента)
    движение = Движения.ЗаказыКлиентов.Добавить();
    движение.ВидДвижения = ВидДвиженияНакопления.Расход;

    движение.Период = Дата;
    движение.Клиент = Клиент;
    движение.ЗаписьКлиента = ДокументОснование;
    движение.Сумма = выборкаНоменклатураДокумента.СуммаВДокументе;
КонецПроцедуры
#КонецОбласти // Движения

// Параметры:
//	превышениеОстатков - Число - Количество превышения остатков
//	наименованиеНоменклатуры - Строка - Наименование Номенклатуры, используется в тексте сообщения
//
Процедура сообщитьПользователюОПревышенииОстатков(Знач превышениеОстатков, Знач наименованиеНоменклатуры)
    сообщение = Новый СообщениеПользователю;
    сообщение.Текст = СтрШаблон("Превышение остатка по номенклатуре: ""%1"" в количестве: ""%2""",
            наименованиеНоменклатуры, превышениеОстатков);
    сообщение.Сообщить();
КонецПроцедуры

Функция получитьБлокировкуИзмененияТоварыНаСкладах() // => БлокировкаДанных
    блокировка = Новый БлокировкаДанных;
    элементБлокировки = блокировка.Добавить("РегистрНакопления.ТоварыНаСкладах");
    элементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
    элементБлокировки.ИсточникДанных = Товары;
    элементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Товар");
    элементБлокировки.УстановитьЗначение("Склад", Склад);

    Возврат блокировка;
КонецФункции

Функция обновитьСтатусОплатыДокументаОснования(Знач записыватьИзменения = Истина)
    Если ЗначениеЗаполнено(ДокументОснование) И ТипЗнч(ДокументОснование) = Тип("Документ.ЗаписьКлиента") Тогда
        ДокументОснование.ОбновитьСтатусОплатыДокумента();
        Если записыватьИзменения Тогда
            ДокументОснование.Записать();
        КонецЕсли;
        Возврат Истина;
    КонецЕсли;

    Возврат Ложь;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
