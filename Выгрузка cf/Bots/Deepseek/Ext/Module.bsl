﻿
Процедура ОбработкаСообщенияСистемыВзаимодействия(Сообщение, ДополнительныеПараметры)     
	
	Попытка		
		Если Строка(Сообщение.Текст) = "UnblockObjectMsg" Тогда 
			Возврат;
		КонецЕсли;                                                                  
		
		Настройки = НастройкиПодключенияПовтИсп.ПолучитьНастройки();
		
		Если Настройки.АдресСервера = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		HTTPСоединение = Новый HTTPСоединение(Настройки.АдресСервера, , , , , 60); 	
		
		HTTPЗапрос = Новый HTTPЗапрос;
		HTTPЗапрос.АдресРесурса = "api/chat";
		HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
		
		Параметры = Новый Структура;
		Параметры.Вставить("id_user", Строка(Сообщение.Автор));
		Параметры.Вставить("message", Строка(Сообщение.Текст)); 
		Параметры.Вставить("url", Настройки.АдресИИ);     
		Параметры.Вставить("token", Настройки.ТокенИИ); 
		Параметры.Вставить("user_bd", Настройки.ПользовательБД);     
		Параметры.Вставить("server_bd", Настройки.СерверБД);     
		Параметры.Вставить("name_bd", Настройки.ИмяБД);     
		Параметры.Вставить("port_bd", Настройки.ПортБД);     
		Параметры.Вставить("password_bd", Настройки.ПарольБД);     
		
		HTTPЗапрос.УстановитьТелоИзСтроки(ОбщегоНазначения.СформироватьТекстJSON(Параметры, "")); 
		
		Ответ = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
		
		Если Ответ.КодСостояния = 200 тогда     
			
			ГуидСообщения = Ответ.ПолучитьТелоКакСтроку(); 
			
			HTTPЗапрос = Новый HTTPЗапрос;
			Параметры.Вставить("id_message", ГуидСообщения);
			
			HTTPЗапрос.АдресРесурса = "api/status";
			HTTPЗапрос.Заголовки.Вставить("Content-Type", "application/json");
			HTTPЗапрос.УстановитьТелоИзСтроки(ОбщегоНазначения.СформироватьТекстJSON(Параметры, ""));   
			
			ВызватьПаузу(1000);
			СчетчикПустых = 0;
			
			Пока Истина Цикл  
				Ответ = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
				
				Если СчетчикПустых = 20 тогда
					ОтветСообщения = СистемаВзаимодействия.СоздатьСообщение(Сообщение.Обсуждение);  
					ОтветСообщения.Текст = "Нет ответа...";	
					ОтветСообщения.Записать(); 	
					Прервать;
				КонецЕсли;
				
				Если Ответ.КодСостояния = 200 тогда   
					Попытка
						Массив = ОбщегоНазначения.ПрочитатьСодержимоеJSON(Ответ.ПолучитьТелоКакСтроку());
					Исключение   
						ОтветСообщения = СистемаВзаимодействия.СоздатьСообщение(Сообщение.Обсуждение);  
						ОтветСообщения.Текст = "ОШИБКА! " + Ответ.ПолучитьТелоКакСтроку();	
						ОтветСообщения.Записать();
						Возврат;
					КонецПопытки;
					
					Если Массив.Количество() = 0 Тогда    
						СчетчикПустых = СчетчикПустых + 1;
						ВызватьПаузу(1000);
						Продолжить;
					Иначе
						СчетчикПустых = 0;
					КонецЕсли;
					
					ТекстСоощения = "";
					Для Каждого стр Из Массив Цикл
						ТекстСоощения = ТекстСоощения +  стр.text;      
						
						Если стр.last Тогда 
							ТекстСоощения = ТекстСоощения + символы.ПС + "КОНЕЦ ОТВЕТА";
						КонецЕсли;
					КонецЦикла;      			
					
					ОтветСообщения = СистемаВзаимодействия.СоздатьСообщение(Сообщение.Обсуждение);				
					ОтветСообщения.Текст = ТекстСоощения;	
					ОтветСообщения.Записать(); 	
					
					Если стр.last Тогда 
						Прервать;
					КонецЕсли;  
					
					ВызватьПаузу(1000);
				Иначе
					ОтветСообщения = СистемаВзаимодействия.СоздатьСообщение(Сообщение.Обсуждение);  
					ОтветСообщения.Текст = "ОШИБКА! " + Ответ.ПолучитьТелоКакСтроку();	
					ОтветСообщения.Записать();
					Прервать;
				КонецЕсли;
			КонецЦикла;	
		Иначе                                                       
			ОтветСообщения = СистемаВзаимодействия.СоздатьСообщение(Сообщение.Обсуждение);  
			ОтветСообщения.Текст = "ОШИБКА! " + Ответ.ПолучитьТелоКакСтроку();	
			ОтветСообщения.Записать();
		КонецЕсли; 
		
	Исключение 
		ОтветСообщения = СистемаВзаимодействия.СоздатьСообщение(Сообщение.Обсуждение);  
		ОтветСообщения.Текст = ОписаниеОшибки();	
		ОтветСообщения.Записать();
	КонецПопытки;
	
	
КонецПроцедуры

