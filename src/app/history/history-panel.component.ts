// ------------------------------------------------------------------------------
//  Copyright (c) Microsoft Corporation.  All Rights Reserved.  Licensed under the MIT License.
// See License in the project root for license information.
// ------------------------------------------------------------------------------
import { ChangeDetectorRef, Component, OnInit } from '@angular/core';

import { getShortQueryText } from '../ApiCallDisplayHelpers';
import { AppComponent } from '../app.component';
import { IGraphApiCall } from '../base';
import { GraphExplorerComponent } from '../GraphExplorerComponent';
import { QueryRunnerService } from '../query-runner.service';
import { saveHistoryToLocalStorage } from './history';

declare let moment: any;

@Component({
  selector: 'history-panel',
  styleUrls: ['./history-panel.component.css'],
  templateUrl: './history-panel.component.html',
  providers: [QueryRunnerService],
})
export class HistoryPanelComponent extends GraphExplorerComponent implements OnInit {
    constructor(private changeDetectorRef: ChangeDetectorRef, private queryRunnerService: QueryRunnerService) {
        super();
    }

    public ngOnInit(): void {
        setInterval(() => {
            for (const historyRecord of AppComponent.requestHistory) {
                historyRecord.relativeDate = moment(historyRecord.requestSentAt).fromNow();
            }
            this.changeDetectorRef.detectChanges();
        }, 5000);
    }

    public closeHistoryPanel = () => {
        (document.querySelector('#history-panel .ms-Panel-closeButton') as any).click();
    };

    public getQueryText(query: IGraphApiCall) {
        return getShortQueryText(query);
    }

    public getSuccessClass(query: IGraphApiCall) {
        return query.statusCode >= 200 && query.statusCode < 300 ? 'success' : 'error';
    }

    public removeQueryFromHistory(query: IGraphApiCall) {
        AppComponent.removeRequestFromHistory(query);
    }

    public clearHistory() {
        AppComponent.requestHistory = [];
        saveHistoryToLocalStorage(AppComponent.requestHistory);
    }

    public handleQueryClick(query: IGraphApiCall) {
        if (!this.isAuthenticated() && query.method !== 'GET') {
            return;
        }

        this.loadQueryIntoEditor(query);
        this.closeHistoryPanel();

        if (query.method === 'GET') {
            this.queryRunnerService.executeExplorerQuery(true);
        }
    }

    public exportQuery(query: IGraphApiCall) {
      const blob = new Blob([query.har], { type: 'text/json' });

      const url = query.requestUrl.slice(8).split('/');
      url.pop(); // Removes leading slash

      const filename = `${url.join('_')}.har`;

      if (window.navigator.msSaveOrOpenBlob) {
        window.navigator.msSaveBlob(blob, filename);
      } else {
        const elem = window.document.createElement('a');
        elem.href = window.URL.createObjectURL(blob);
        elem.download = filename;
        document.body.appendChild(elem);
        elem.click();
        document.body.removeChild(elem);
      }
    }
}
